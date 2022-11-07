#based on: https://github.com/sgrvinod/a-PyTorch-Tutorial-to-Object-Detection

class Ssd300 < Torch::NN::Module
  attr_accessor :priors_cxcy

  def initialize(n_classes)
    super()

    @n_classes = n_classes

    @base = VggBase.new
    @aux_convs = AuxiliaryConvolutions.new
    @pred_convs = PredictionConvolutions.new(n_classes)

    @rescale_factors = Torch::NN::Parameter.new(Torch::FloatTensor.new(1, 512, 1, 1))
    Torch::NN::Init.constant!(@rescale_factors, 20)

    @priors_cxcy = create_prior_boxes
    @n_priors = @priors_cxcy.size(0)
  end

  def forward(image)
    conv4_3_feats, conv7_feats = @base.call(image)

    # Rescale conv4_3 after L2 norm
    norm = conv4_3_feats.pow(2).sum(dim: 1, keepdim: true).sqrt()  # (N, 1, 38, 38)
    conv4_3_feats = conv4_3_feats / norm  # (N, 512, 38, 38)
    conv4_3_feats = conv4_3_feats * @rescale_factors  # (N, 512, 38, 38)
    # (PyTorch autobroadcasts singleton dimensions during arithmetic)

    # Run auxiliary convolutions (higher level feature map generators)
    conv8_2_feats, conv9_2_feats, conv10_2_feats, conv11_2_feats = @aux_convs.call(conv7_feats)  # (N, 512, 10, 10),  (N, 256, 5, 5), (N, 256, 3, 3), (N, 256, 1, 1)

    # Run prediction convolutions (predict offsets w.r.t prior-boxes and classes in each resulting localization box)
    locs, classes_scores = @pred_convs.call(conv4_3_feats, conv7_feats, conv8_2_feats, conv9_2_feats, conv10_2_feats, conv11_2_feats)  # (N, 8732, 4), (N, 8732, n_classes)

    [locs, classes_scores]
  end

  def create_prior_boxes
    fmap_dims = {conv4_3: 38,
                 conv7: 19,
                 conv8_2: 10,
                 conv9_2: 5,
                 conv10_2: 3,
                 conv11_2: 1}

    obj_scales = {conv4_3: 0.1,
                  conv7: 0.2,
                  conv8_2: 0.375,
                  conv9_2: 0.55,
                  conv10_2: 0.725,
                  conv11_2: 0.9}

    aspect_ratios = {conv4_3: [1.0, 20.0, 0.5],
                     conv7: [1.0, 2.0, 3.0, 0.5, 0.333],
                     conv8_2: [1.0, 2.0, 3.0, 0.5, 0.333],
                     conv9_2: [1.0, 2.0, 3.0, 0.5, 0.333],
                     conv10_2: [1.0, 2.0, 0.5],
                     conv11_2: [1.0, 2.0, 0.5]}

    fmaps = fmap_dims.keys

    prior_boxes = []

    fmaps.each_with_index do |fmap, k|
      (0...fmap_dims[fmap]).each do |i|
        (0...fmap_dims[fmap]).each do |j|
          cx = (j + 0.5) / fmap_dims[fmap]
          cy = (i + 0.5) / fmap_dims[fmap]

          aspect_ratios[fmap].each do |ratio|
            prior_boxes << [cx, cy, obj_scales[fmap] * Math.sqrt(ratio), obj_scales[fmap] / Math.sqrt(ratio)]

            # For an aspect ratio of 1, use an additional prior whose scale is the geometric mean of the
            # scale of the current feature map and the scale of the next feature map
            if ratio == 1.0
              if k < fmaps.length-1
                additional_scale = Math.sqrt(obj_scales[fmap] * obj_scales[fmaps[k + 1]])
                # For the last feature map, there is no "next" feature map
              else
                additional_scale = 1.0
              end
              prior_boxes << [cx, cy, additional_scale, additional_scale]
            end
          end
        end
      end
    end

    prior_boxes = Torch.tensor(prior_boxes)  # (8732, 4)
    prior_boxes.clamp!(0, 1)  # (8732, 4)

    prior_boxes
  end

  def detect_objects(predicted_locs, predicted_scores, min_score, max_overlap, top_k)
    batch_size = predicted_locs.size(0)
    predicted_scores = F.softmax(predicted_scores, dim: 2)

    all_images_boxes = []
    all_images_labels = []
    all_images_scores = []

    raise unless n_priors == predicted_locs.size(1) && n_priors == predicted_scores.size(1)

    (0...batch_size).each do |i|
      decoded_locs = Utils.cxcy_to_xy(Utils.gcxgcy_to_cxcy(predicted_locs[i], @priors_cxcy))

      image_boxes = []
      image_labels = []
      image_scores = []

      max_scores, best_label = predicted_scores[i].max(dim: 1)

      (1...@n_classes).each do |c|
        class_scores = predicted_scores[i][0.., c]  # (8732)
        score_above_min_score = class_scores > min_score  # torch.uint8 (byte) tensor, for indexing
        n_above_min_score = score_above_min_score.sum.item
        continue if n_above_min_score == 0

        class_scores = class_scores[score_above_min_score]  # (n_qualified), n_min_score <= 8732
        class_decoded_locs = decoded_locs[score_above_min_score]  # (n_qualified, 4)

        # Sort predicted boxes and scores by scores
        class_scores, sort_ind = class_scores.sort(dim: 0, descending: True)  # (n_qualified), (n_min_score)
        class_decoded_locs = class_decoded_locs[sort_ind]  # (n_min_score, 4)

        # Find the overlap between predicted boxes
        overlap = Utils.find_jaccard_overlap(class_decoded_locs, class_decoded_locs)  # (n_qualified, n_min_score)

        # Non-Maximum Suppression (NMS)

        # A torch.uint8 (byte) tensor to keep track of which predicted boxes to suppress
        # 1 implies suppress, 0 implies don't suppress
        suppress = torch.zeros((n_above_min_score), dtype: torch.uint8)  # (n_qualified)

        (0...class_decoded_locs.size(0)).each do |box|
          # If this box is already marked for suppression
          next if suppress[box] == 1

          # Suppress boxes whose overlaps (with this box) are greater than maximum overlap
          # Find such boxes and update suppress indices
          suppress = Torch.max(suppress, overlap[box] > max_overlap)
          # The max operation retains previously suppressed boxes, like an 'OR' operation

          # Don't suppress this box, even though it has an overlap of 1 with itself
          suppress[box] = 0
        end

        image_boxes.append(class_decoded_locs[1 - suppress])
        image_labels.append(Torch.tensor((1 - suppress).sum().item() * [c]))
        image_scores.append(class_scores[1 - suppress])
      end

      if image_boxes.empty?
        image_boxes << torch.tensor([[0.0, 0.0, 1.0, 1.0]])
        image_labels << torch.tensor([0])
        image_scores << torch.tensor([0.0])
      end

      # Concatenate into single tensors
      image_boxes = Torch.cat(image_boxes, dim: 0)  # (n_objects, 4)
      image_labels = Torch.cat(image_labels, dim: 0)  # (n_objects)
      image_scores = Torch.cat(image_scores, dim: 0)  # (n_objects)
      n_objects = image_scores.size(0)

      # Keep only the top k objects
      if n_objects > top_k
        image_scores, sort_ind = image_scores.sort(dim: 0, descending: true)
        image_scores = image_scores[:top_k]  # (top_k)
        image_boxes = image_boxes[sort_ind][:top_k]  # (top_k, 4)
        image_labels = image_labels[sort_ind][:top_k]  # (top_k)
      end

      # Append to lists that store predicted boxes and scores for all images
      all_images_boxes << image_boxes
      all_images_labels << image_labels
      all_images_scores << image_scores
    end
  end
end
