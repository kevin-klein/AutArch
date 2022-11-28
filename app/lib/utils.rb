#based on: https://github.com/sgrvinod/a-PyTorch-Tutorial-to-Object-Detection

module Utils
  extend self

  # include TorchVision::Transforms

  def find_intersection(set_1, set_2)
    # Find the intersection of every box combination between two sets of boxes that are in boundary coordinates.
    # :param set_1: set 1, a tensor of dimensions (n1, 4)
    # :param set_2: set 2, a tensor of dimensions (n2, 4)
    # :return: intersection of each of the boxes in set 1 with respect to each of the boxes in set 2, a tensor of dimensions (n1, n2)

    # PyTorch auto-broadcasts singleton dimensions
    lower_bounds = Torch.max(set_1[0..., ...2].unsqueeze(1), set_2[0..., ...2].unsqueeze(0))  # (n1, n2, 2)
    upper_bounds = Torch.min(set_1[0..., 2...].unsqueeze(1), set_2[0..., 2...].unsqueeze(0))  # (n1, n2, 2)
    intersection_dims = Torch.clamp(upper_bounds - lower_bounds, min: 0)  # (n1, n2, 2)
    intersection_dims[0..., 0..., 0] * intersection_dims[0..., 0..., 1]  # (n1, n2)
  end

  def find_jaccard_overlap(set_1, set_2)
    # Find the Jaccard Overlap (IoU) of every box combination between two sets of boxes that are in boundary coordinates.
    # :param set_1: set 1, a tensor of dimensions (n1, 4)
    # :param set_2: set 2, a tensor of dimensions (n2, 4)
    # :return: Jaccard Overlap of each of the boxes in set 1 with respect to each of the boxes in set 2, a tensor of dimensions (n1, n2)

    # Find intersections
    intersection = find_intersection(set_1, set_2)  # (n1, n2)

    # Find areas of each box in both sets
    areas_set_1 = (set_1[0.., 2] - set_1[0.., 0]) * (set_1[0.., 3] - set_1[0.., 1])  # (n1)
    areas_set_2 = (set_2[0.., 2] - set_2[0.., 0]) * (set_2[0.., 3] - set_2[0.., 1])  # (n2)

    # Find the union
    # PyTorch auto-broadcasts singleton dimensions
    union = areas_set_1.unsqueeze(1) + areas_set_2.unsqueeze(0) - intersection  # (n1, n2)

    intersection / union  # (n1, n2)
  end

  def cxcy_to_xy(cxcy)
    x_min_y_min = cxcy[0.., ..1] - (cxcy[0.., 2..] / 2)
    x_max_y_max = cxcy[0.., ..1] + (cxcy[0.., 2..] / 2)

    Torch.cat([x_min_y_min,  x_max_y_max], 1)
  end

  def xy_to_cxcy(xy)
    Torch.cat([(xy[0.., 2..] + xy[0.., ..1]) / 2,  # c_x, c_y
                      xy[0.., 2..] - xy[0.., ..1]], 1)  # w, h
  end

  def cxcy_to_gcxgcy(cxcy, priors_cxcy)
    Torch.cat([(cxcy[0.., ..1] - priors_cxcy[0.., ..1]) / (priors_cxcy[0.., 2..] / 10),  # g_c_x, g_c_y
                      Torch.log(cxcy[0.., 2..] / priors_cxcy[0.., 2..]) * 5], 1)  # g_w, g_h
  end

  def gcxgcy_to_cxcy(gcxgcy, priors_cxcy)
    Torch.cat([gcxgcy[0.., ..1] * priors_cxcy[0.., 2..] / 10 + priors_cxcy[0.., ..1],  # c_x, c_y
                      torch.exp(gcxgcy[0.., 2..] / 5) * priors_cxcy[0.., 2..]], 1)  # w, h
  end

  # Some augmentation functions below have been adapted from
  # From https://github.com/amdegroot/ssd.pytorch/blob/master/utils/augmentations.py
  def expand(image, boxes, filler)
    # Perform a zooming out operation by placing the image in a larger canvas of filler material.
    # Helps to learn to detect smaller objects.
    # :param image: image, a tensor of dimensions (3, original_h, original_w)
    # :param boxes: bounding boxes in boundary coordinates, a tensor of dimensions (n_objects, 4)
    # :param filler: RBG values of the filler material, a list like [R, G, B]
    # :return: expanded image, updated bounding box coordinates
    # Calculate dimensions of proposed expanded (zoomed-out) image
    original_h = image.size(1)
    original_w = image.size(2)
    max_scale = 4
    scale = rand(1..max_scale)
    new_h = (scale * original_h).to_i
    new_w = (scale * original_w).to_i

    # Create such an image with the filler
    filler = Torch.tensor(filler)  # (3)
    new_image = Torch.ones(3, new_h, new_w, dtype: torch.float) * filler.unsqueeze(1).unsqueeze(1)  # (3, new_h, new_w)
    # Note - do not use expand() like new_image = filler.unsqueeze(1).unsqueeze(1).expand(3, new_h, new_w)
    # because all expanded values will share the same memory, so changing one pixel will change all

    # Place the original image at random coordinates in this new image (origin at top-left of image)
    left = rand(0..(new_w - original_w))
    right = left + original_w
    top = rand(0..(new_h - original_h))
    bottom = top + original_h
    new_image[0.., top...bottom, left...right] = image

    # Adjust bounding boxes' coordinates accordingly
    new_boxes = boxes + Torch.tensor([left, top, left, top]).unsqueeze(
        0)  # (n_objects, 4), n_objects is the no. of objects in this image

    [new_image, new_boxes]
  end

  def random_crop(image, boxes, labels, difficulties)
    # Performs a random crop in the manner stated in the paper. Helps to learn to detect larger and partial objects.
    # Note that some objects may be cut out entirely.
    # Adapted from https://github.com/amdegroot/ssd.pytorch/blob/master/utils/augmentations.py
    # :param image: image, a tensor of dimensions (3, original_h, original_w)
    # :param boxes: bounding boxes in boundary coordinates, a tensor of dimensions (n_objects, 4)
    # :param labels: labels of objects, a tensor of dimensions (n_objects)
    # :param difficulties: difficulties of detection of these objects, a tensor of dimensions (n_objects)
    # :return: cropped image, updated bounding box coordinates, updated labels, updated difficulties
    original_h = image.size(1)
    original_w = image.size(2)
    # Keep choosing a minimum overlap until a successful crop is made
    loop do
      # Randomly draw the value for minimum overlap
      min_overlap = ([0.0, 0.1, 0.3, 0.5, 0.7, 0.9, nil]).sample  # 'None' refers to no cropping

      # If not cropping
      if min_overlap.nil?
        return [image, boxes, labels, difficulties]
      end

      # Try up to 50 times for this choice of minimum overlap
      # This isn't mentioned in the paper, of course, but 50 is chosen in paper authors' original Caffe repo
      max_trials = 50
      (0...max_trials).each do
        # Crop dimensions must be in [0.3, 1] of original dimensions
        # Note - it's [0.1, 1] in the paper, but actually [0.3, 1] in the authors' repo
        min_scale = 0.3
        scale_h = rand(min_scale..1)
        scale_w = rand(min_scale..1)
        new_h = (scale_h * original_h).to_i
        new_w = (scale_w * original_w).to_i

        # Aspect ratio has to be in [0.5, 2]
        aspect_ratio = new_h / new_w
        next unless aspect_ratio.between?(0.5, 2)

        # Crop coordinates (origin at top-left of image)
        left = rand(0..(original_w - new_w))
        right = left + new_w
        top = rand(0..(original_h - new_h))
        bottom = top + new_h
        crop = torch.tensor([left, top, right, bottom])  # (4)

        # Calculate Jaccard overlap between the crop and the bounding boxes
        overlap = find_jaccard_overlap(crop.unsqueeze(0),
                                       boxes)  # (1, n_objects), n_objects is the no. of objects in this image
        overlap = overlap.squeeze(0)  # (n_objects)

        # If not a single bounding box has a Jaccard overlap of greater than the minimum, try again
        next if overlap.max().item() < min_overlap

        # Crop image
        new_image = image[0.., top..bottom, left..right]  # (3, new_h, new_w)

        # Find centers of original bounding boxes
        bb_centers = (boxes[0.., ...2] + boxes[0.., 2...]) / 2.0  # (n_objects, 2)

        # Find bounding boxes whose centers are in the crop
        centers_in_crop = (bb_centers[0.., 0] > left) * (bb_centers[0.., 0] < right) * (bb_centers[0.., 1] > top) * (
                bb_centers[0.., 1] < bottom)  # (n_objects), a Torch uInt8/Byte tensor, can be used as a boolean index

        # If not a single bounding box has its center in the crop, try again
        next unless centers_in_crop.any

        # Discard bounding boxes that don't meet this criterion
        new_boxes = boxes[centers_in_crop, 0..]
        new_labels = labels[centers_in_crop]
        new_difficulties = difficulties[centers_in_crop]

        # Calculate bounding boxes' new coordinates in the crop
        new_boxes[0..., ...2] = torch.max(new_boxes[0.., ...2], crop[...2])  # crop[:2] is [left, top]
        new_boxes[0..., ...2] -= crop[..0]
        new_boxes[0..., 2...] = torch.min(new_boxes[0..., 2...], crop[2...])  # crop[2:] is [right, bottom]
        new_boxes[0..., 2...] -= crop[...2]

        return [new_image, new_boxes, new_labels, new_difficulties]
      end
    end
  end


  def flip(image, boxes)
    # Flip image horizontally.
    # :param image: image, a PIL Image
    # :param boxes: bounding boxes in boundary coordinates, a tensor of dimensions (n_objects, 4)
    # :return: flipped image, updated bounding box coordinates
    # Flip image
    new_image = FT.hflip(image)

    # Flip boxes
    new_boxes = boxes
    new_boxes[0..., 0] = image.width - boxes[0..., 0] - 1
    new_boxes[0..., 2] = image.width - boxes[0..., 2] - 1
    new_boxes = new_boxes[0..., [2, 1, 0, 3]]

    [new_image, new_boxes]
  end


  def resize(image, boxes, dims: [300, 300], return_percent_coords: true)
    # Resize image. For the SSD300, resize to (300, 300).
    # Since percent/fractional coordinates are calculated for the bounding boxes (w.r.t image dimensions) in this process,
    # you may choose to retain them.
    # :param image: image, a PIL Image
    # :param boxes: bounding boxes in boundary coordinates, a tensor of dimensions (n_objects, 4)
    # :return: resized image, updated bounding box coordinates (or fractional coordinates, in which case they remain the same)
    # Resize image
    new_image = Functional.resize(image, dims)

    # Resize bounding boxes
    old_dims = Torch.tensor([image.width, image.height, image.width, image.height]).unsqueeze(0)
    new_boxes = boxes / old_dims  # percent coordinates

    unless return_percent_coords
      new_dims = Torch.tensor([dims[1], dims[0], dims[1], dims[0]]).unsqueeze(0)
      new_boxes = new_boxes * new_dims
    end

    [new_image, new_boxes]
  end

  def transform(image, boxes, labels, split)
    # Apply the transformations above.
    # :param image: image, a PIL Image
    # :param boxes: bounding boxes in boundary coordinates, a tensor of dimensions (n_objects, 4)
    # :param labels: labels of objects, a tensor of dimensions (n_objects)
    # :param difficulties: difficulties of detection of these objects, a tensor of dimensions (n_objects)
    # :param split: one of 'TRAIN' or 'TEST', since different sets of transformations are applied
    # :return: transformed image, transformed bounding box coordinates, transformed labels, transformed difficulties
    # assert split in {'TRAIN', 'TEST'}

    # Mean and standard deviation of ImageNet data that our base VGG from torchvision was trained on
    # see: https://pytorch.org/docs/stable/torchvision/models.html
    # mean = [0.485, 0.456, 0.406]
    # std = [0.229, 0.224, 0.225]

    new_image = image
    new_boxes = boxes
    new_labels = labels
    # Skip the following operations for evaluation/testing
    # if split == 'TRAIN':
    #     # Convert PIL image to Torch tensor
    #     new_image = FT.to_tensor(new_image)
    #
    #     # Expand image (zoom out) with a 50% chance - helpful for training detection of small objects
    #     # Fill surrounding space with the mean of ImageNet data that our base VGG was trained on
    #     if random.random() < 0.5:
    #         new_image, new_boxes = expand(new_image, boxes, filler=mean)
    #
    #     # Randomly crop image (zoom in)
    #     new_image, new_boxes, new_labels, new_difficulties = random_crop(new_image, new_boxes, new_labels,
    #                                                                      new_difficulties)
    #
    #     # Convert Torch tensor to PIL image
    #     new_image = FT.to_pil_image(new_image)
    #
    #     # Flip image with a 50% chance
    #     if random.random() < 0.5:
    #         new_image, new_boxes = flip(new_image, new_boxes)

    # Resize image to (300, 300) - this also converts absolute boundary coordinates to their fractional form
    new_image, new_boxes = resize(new_image, new_boxes, dims: [300, 300])

    # Convert PIL image to Torch tensor
    new_image = Functional.to_tensor(new_image)

    [new_image, new_boxes, new_labels]
  end


  def adjust_learning_rate(optimizer, scale)
    # Scale learning rate by a specified factor.
    # :param optimizer: optimizer whose learning rate must be shrunk.
    # :param scale: factor to multiply learning rate with.
    optimizer.param_groups.each do |param_group|
      param_group[:lr] *= scale
    end

    print("DECAYING learning rate.\n The new LR is #{optimizer.param_groups[1][:lr]}\n")
  end

def accuracy(scores, targets, k)
    # Computes top-k accuracy, from predicted and true labels.
    # :param scores: scores from the model
    # :param targets: true labels
    # :param k: k in top-k accuracy
    # :return: top-k accuracy
    batch_size = targets.size(0)
    _, ind = scores.topk(k, 1, true, true)
    correct = ind.eq(targets.view(-1, 1).expand_as(ind))
    correct_total = correct.view(-1).float.sum  # 0D tensor

    correct_total.item * (100.0 / batch_size)
  end


  def save_checkpoint(epoch, model, optimizer)
    # Save model checkpoint.
    # :param epoch: epoch number
    # :param model: model
    # :param optimizer: optimizer
    state = {epoch: epoch,
             model: model,
             optimizer: optimizer}
    filename = 'checkpoint_ssd300.pth.tar'
    Torch.save(state, filename)
  end

  def clip_gradient(optimizer, grad_clip)
    # Clips gradients computed during backpropagation to avoid explosion of gradients.
    # :param optimizer: optimizer with the gradients to be clipped
    # :param grad_clip: clip value
    optimizer.param_groups.each do |group|
      group['params'].each do |param|
        unless param.grad.nil?
          param.grad.data.clamp_(-grad_clip, grad_clip)
        end
      end
    end
  end
end
