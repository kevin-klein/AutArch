module Vision
  module CenterNet
    class KeypointDetectionLoss < Torch::NN::Module
      def initialize(heatmap_weight: 1.0, visibility_weight: 0.5,
                    focal_gamma: 2.0, focal_alpha: 0.25,
                    kl_weight: 0.1)
        super()
        @heatmap_weight = heatmap_weight
        @visibility_weight = visibility_weight
        @focal_gamma = focal_gamma
        @focal_alpha = focal_alpha
        @kl_weight = kl_weight
      end

      def forward(pred_heatmaps, target_heatmaps, pred_visibility, target_visibility)
        # 1. Heatmap Loss: Modified Focal Loss for heatmaps
        heatmap_loss = focal_heatmap_loss(pred_heatmaps, target_heatmaps)

        # 2. Visibility Loss: Weighted Binary Cross-Entropy
        visibility_loss = weighted_bce_loss(pred_visibility, target_visibility)

        # 3. Consistency Loss: KL divergence between heatmap confidence and visibility
        consistency_loss = consistency_kl_loss(pred_heatmaps, pred_visibility, target_heatmaps)

        total_loss = (@heatmap_weight * heatmap_loss +
                      @visibility_weight * visibility_loss +
                      @kl_weight * consistency_loss)

        {
          total: total_loss,
          heatmap: heatmap_loss,
          visibility: visibility_loss,
          consistency: consistency_loss
        }
      end

      private

      def focal_heatmap_loss(pred, target)
        # Focal loss variant for heatmap regression
        # Give more weight to difficult examples (far from ground truth)

        # Calculate probability of correct prediction
        pt = Torch.exp(-Torch.abs(pred - target))

        # Focal weight
        focal_weight = (1 - pt) ** @focal_gamma

        # Alpha-balanced weight
        alpha_weight = @focal_alpha * target + (1 - @focal_alpha) * (1 - target)

        # Base loss (smooth L1)
        base_loss = Torch.where(
          Torch.abs(pred - target).lt(1.0),
          0.5 * (pred - target) ** 2,
          Torch.abs(pred - target) - 0.5
        )

        loss = alpha_weight * focal_weight * base_loss

        # Apply mask based on target (ignore completely black heatmaps)
        mask = (target.sum(dim=[2, 3], keepdim: true).gt(0)).float()
        loss = loss * mask

        return loss.sum() / (mask.sum() + 1e-8)
      end

      def weighted_bce_loss(pred, target)
        # Weight BCE to handle class imbalance (visible vs missing)

        # Calculate class weights
        positive_weight = (target.eq(0)).float().sum() / (target.numel() + 1e-8)
        negative_weight = (target.eq(1)).float().sum() / (target.numel() + 1e-8)

        # Weighted BCE
        bce = -(
          positive_weight * target * Torch.log(pred.clamp(min=1e-8)) +
          negative_weight * (1 - target) * Torch.log((1 - pred).clamp(min=1e-8))
        )

        return bce.mean()
      end

      def consistency_kl_loss(pred_heatmaps, pred_visibility, target_heatmaps)
        # KL divergence between heatmap confidence and visibility prediction
        # Encourages consistency between these two predictions

        # Get max confidence from heatmaps for each keypoint
        heatmap_confidence = pred_heatmaps.max(dim=2)[0].max(dim=2)[0]  # [B, K]

        # Normalize to probabilities
        heatmap_prob = Torch.sigmoid(heatmap_confidence - 0.5)
        visibility_prob = pred_visibility

        # KL divergence
        kl_loss = (visibility_prob *
                  Torch.log(visibility_prob / (heatmap_prob + 1e-8)) +
                  (1 - visibility_prob) *
                  Torch.log((1 - visibility_prob) / (1 - heatmap_prob + 1e-8)))

        # Only apply where target heatmap has signal
        has_target = (target_heatmaps.max(dim=2)[0].max(dim=2)[0].gt(0)).float()
        kl_loss = kl_loss * has_target

        return kl_loss.sum() / (has_target.sum() + 1e-8)
      end
    end
  end
end
