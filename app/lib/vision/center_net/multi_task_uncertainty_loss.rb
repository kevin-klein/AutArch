module Vision
  module CenterNet
    class MultiTaskUncertaintyLoss < Torch::NN::Module
      # Based on: https://arxiv.org/abs/1705.07115
      def initialize(learnable_weights: true)
        super()
        @learnable_weights = learnable_weights

        if learnable_weights
          # Learn log variances for each task
          @log_var_heatmap = Torch::NN::Parameter.new(Torch.zeros(1))
          @log_var_visibility = Torch::NN::Parameter.new(Torch.zeros(1))
        end
      end

      def forward(pred_heatmaps, target_heatmaps, pred_visibility, target_visibility)
        # Base losses
        heatmap_loss = Torch::NN::Functional.mse_loss(pred_heatmaps, target_heatmaps, reduction: 'none')
        visibility_loss = Torch::NN::Functional.binary_cross_entropy(pred_visibility, target_visibility, reduction: 'none')

        if @learnable_weights
          # Weight by learned uncertainty
          heatmap_loss = Torch.exp(-@log_var_heatmap) * heatmap_loss + 0.5 * @log_var_heatmap
          visibility_loss = Torch.exp(-@log_var_visibility) * visibility_loss + 0.5 * @log_var_visibility

          total_loss = heatmap_loss.mean() + visibility_loss.mean()

          return {
            total: total_loss,
            heatmap: heatmap_loss.mean(),
            visibility: visibility_loss.mean(),
            log_var_heatmap: @log_var_heatmap,
            log_var_visibility: @log_var_visibility
          }
        else
          # Fixed weighting
          total_loss = heatmap_loss.mean() + 0.5 * visibility_loss.mean()

          return {
            total: total_loss,
            heatmap: heatmap_loss.mean(),
            visibility: visibility_loss.mean()
          }
        end
      end
    end
  end
end
