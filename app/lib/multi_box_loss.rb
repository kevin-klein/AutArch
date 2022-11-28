class MultiBoxLoss # < Torch::NN::Module
  # include Torch::NN

  def initialize(priors_cxcy, threshold: 0.5, neg_pos_ratio: 3, alpha: 1.0)
    super()

    @priors_cxcy = priors_cxcy
    @priors_xy = ::Utils.cxcy_to_xy(priors_cxcy)
    @threshold = threshold
    @neg_pos_ratio = neg_pos_ratio
    @alpha = alpha

    @smooth_l1 = L1Loss.new
    @cross_entropy = CrossEntropyLoss.new(reduction: 'none')
  end

  def forward(predicted_locs, predicted_scores, boxes, labels)
    # :param predicted_locs: predicted locations/boxes w.r.t the 8732 prior boxes, a tensor of dimensions (N, 8732, 4)
    # :param predicted_scores: class scores for each of the encoded locations/boxes, a tensor of dimensions (N, 8732, n_classes)
    # :param boxes: true  object bounding boxes in boundary coordinates, a list of N tensors
    # :param labels: true object labels, a list of N tensors
    # :return: multibox loss, a scalar

    batch_size = predicted_locs.size(0)
    n_priors = @priors_cxcy.size(0)
    n_classes = predicted_scores.size(2)

    raise unless n_priors == predicted_locs.size(1) && n_priors == predicted_scores.size(1)

    true_locs = Torch.zeros([batch_size, n_priors, 4], dtype: Torch.float)  # (N, 8732, 4)
    true_classes = Torch.zeros([batch_size, n_priors], dtype: Torch.long)  # (N, 8732)

    (0...batch_size).each do |i|
      n_objects = boxes[i].size(0)
      overlap = ::Utils.find_jaccard_overlap(boxes[i], @priors_xy)

      # For each prior, find the object that has the maximum overlap
      overlap_for_each_prior, object_for_each_prior = overlap.max(dim: 0)  # (8732)

      # We don't want a situation where an object is not represented in our positive (non-background) priors -
      # 1. An object might not be the best object for all priors, and is therefore not in object_for_each_prior.
      # 2. All priors with the object may be assigned as background based on the threshold (0.5).

      # To remedy this -
      # First, find the prior that has the maximum overlap for each object.
      _, prior_for_each_object = overlap.max(dim: 1)  # (N_o)

      # Then, assign each object to the corresponding maximum-overlap-prior. (This fixes 1.)
      # ap n_objects
      # ap object_for_each_prior
      # ap prior_for_each_object
      object_for_each_prior[prior_for_each_object] = Torch.tensor((0...n_objects).to_a)

      # To ensure these priors qualify, artificially give them an overlap of greater than 0.5. (This fixes 2.)
      overlap_for_each_prior[prior_for_each_object] = 1.0

      # Labels for each prior
      label_for_each_prior = labels[i][object_for_each_prior]  # (8732)
      # Set priors whose overlaps with objects are less than the threshold to be background (no object)
      label_for_each_prior = label_for_each_prior.numo

      overlap_for_each_prior.to_a.each_with_index do |overlap, index|
        if overlap < @threshold
          label_for_each_prior[index] = 0
        end
      end

      # Store
      true_classes[i] = label_for_each_prior

      # Encode center-size object coordinates into the form we regressed predicted boxes to
      true_locs[i] = ::Utils.cxcy_to_gcxgcy(::Utils.xy_to_cxcy(boxes[i][object_for_each_prior]), @priors_cxcy)  # (8732, 4)
    end

    # Identify priors that are positive (object/non-background)
    positive_priors = Torch.zeros(true_classes.shape, dtype: :bool)
    true_classes.to_a.each_with_index do |row, row_index|
      row.each_with_index do |item, index|
        positive_priors[row_index, index] = item != 0
      end
    end

    # positive_priors = true_classes != 0  # (N, 8732)

    # LOCALIZATION LOSS

    # Localization loss is computed only over positive (non-background) priors

    # ap
    loc_loss = @smooth_l1.call(predicted_locs[positive_priors], true_locs[positive_priors])  # (), scalar

    # Note: indexing with a torch.uint8 (byte) tensor flattens the tensor when indexing is across multiple dimensions (N & 8732)
    # So, if predicted_locs has the shape (N, 8732, 4), predicted_locs[positive_priors] will have (total positives, 4)

    # CONFIDENCE LOSS

    # Confidence loss is computed over positive priors and the most difficult (hardest) negative priors in each image
    # That is, FOR EACH IMAGE,
    # we will take the hardest (neg_pos_ratio * n_positives) negative priors, i.e where there is maximum loss
    # This is called Hard Negative Mining - it concentrates on hardest negatives in each image, and also minimizes pos/neg imbalance

    # Number of positive and hard-negative priors per image
    n_positives = positive_priors.sum(dim: 1)  # (N)
    n_hard_negatives = @neg_pos_ratio * n_positives  # (N)

    # First, find the loss for all priors

    conf_loss_all = @cross_entropy.call(predicted_scores.view(-1, n_classes), true_classes.view(-1))  # (N * 8732)
    conf_loss_all = conf_loss_all.view(batch_size, n_priors)  # (N, 8732)

    # We already know which priors are positive
    conf_loss_pos = conf_loss_all[positive_priors]  # (sum(n_positives))

    # Next, find which priors are hard-negative
    # To do this, sort ONLY negative priors in each image in order of decreasing loss and take top n_hard_negatives
    conf_loss_neg = conf_loss_all.clone  # (N, 8732)
    conf_loss_neg[positive_priors] = 0.0  # (N, 8732), positive priors are ignored (never in top n_hard_negatives)
    conf_loss_neg, _ = conf_loss_neg.sort(dim: 1, descending: true)  # (N, 8732), sorted by decreasing hardness
    hardness_ranks = Torch.tensor((0...n_priors)).unsqueeze(0).expand_as(conf_loss_neg)  # (N, 8732)

    hard_negatives = Torch.zeros(true_classes.shape, dtype: :bool)
    hardness_ranks.to_a.each_with_index do |row, row_index|
      row.each_with_index do |item, col_index|
        hard_negatives[row_index, col_index] = item < n_hard_negatives.unsqueeze(1)[row_index].item
      end
    end

    conf_loss_hard_neg = conf_loss_neg[hard_negatives]  # (sum(n_hard_negatives))

    # As in the paper, averaged over positive priors only, although computed over both positive and hard-negative priors
    conf_loss = (conf_loss_hard_neg.sum + conf_loss_pos.sum) / n_positives.sum.float  # (), scalar

    # TOTAL LOSS
    conf_loss + @alpha * loc_loss
  end
end
