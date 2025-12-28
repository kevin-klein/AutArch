module Vision
  module CenterNet
    class Trainer
      def initialize
        transforms = TorchVision::Transforms::Compose.new([
          TorchVision::Transforms::Resize.new([256, 256]),
          TorchVision::Transforms::ToTensor.new
        ])
        @dataset = Vision::KeypointDataset.new("training_data/Keynote Skeletons.json",
          "training_data/skeleton_keypoint_images",
          input_size: 256,
          heatmap_size: 64,
          transform: transforms,
          max_persons_per_image: 1
        )
      end

      def train(model, epochs: 50, batch_size: 8, lr: 1e-4, device: "cuda")
        model.to(device)
        model.train
        optimizer = Torch::Optim::Adam.new(model.parameters, lr: lr)

        criterion = KeypointDetectionLoss.new
        criterion.to(device)

        epochs.times do |epoch|
          total_loss = 0.0
          batches = 0

          # Shuffle indices
          indices = (0...@dataset.size).to_a.shuffle

          0.step(indices.size - 1, batch_size) do |start_idx|
            batch_indices = indices[start_idx, batch_size]
            next if batch_indices.nil? || batch_indices.empty?

            # Initialize batch tensors
            batch_images = []
            batch_heatmaps = []
            batch_visibility = []

            batch_indices.each do |idx|
              sample = @dataset[idx]
              batch_images << sample[:image]
              batch_heatmaps << sample[:heatmaps]
              batch_visibility << sample[:visibility]
            end

            # Stack into batch tensors
            images = Torch.stack(batch_images, 0).to(device)
            target_heatmaps = Torch.stack(batch_heatmaps, 0).to(device)
            target_visibility = Torch.stack(batch_visibility, 0).to(device)

            # Forward pass
            output = model.call(images)
            pred_heatmaps = output[:heatmaps]
            pred_visibility = output[:visibility]


            # Combined loss with weighting
            loss = criterion.call(pred_heatmaps, target_heatmaps, pred_visibility, target_visibility)

            # Backward pass
            optimizer.zero_grad
            loss[:total].backward
            optimizer.step

            total_loss += loss[:total].item
            batches += 1

            if batches % 10 == 0
              puts "Epoch #{epoch + 1}, Batch #{batches}: Loss = #{loss[:total].item.round(4)}"
            end
          end

          avg_loss = total_loss / batches if batches > 0
          puts "Epoch #{epoch + 1} completed. Average loss: #{avg_loss.round(4)}"
        end

        Torch.save(model.state_dict, "models/center_net_keypoints.pth")
      end
    end
  end
end
