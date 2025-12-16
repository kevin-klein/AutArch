module Vision
  module CenterNet
    class Trainer
      def initialize
        @data = Vision::KeypointDataset.parse_labelstudio_json("training_data/Keynote Skeletons.json", "training_data/skeleton_keypoint_images")
        @dataset = Vision::KeypointDataset.new(@data, downsample: 32)
      end

      def train(model, epochs: 50, batch_size: 8, lr: 1e-4, device: "cpu")
        model.to(device)
        opt = Torch::Optim::AdamW.new(model.parameters, lr: lr)

        indices = (0...@dataset.length).to_a

        epochs.times do |epoch|
          indices.shuffle!
          total_loss = 0.0
          steps = 0

          indices.each_slice(batch_size) do |batch_idxs|
            imgs, tgt = @dataset.get_batch(batch_idxs)

            imgs = imgs.to(device)
            tgt.each { |k, v| tgt[k] = v.to(device) }

            out = model.call(imgs)

            loss_hm = Vision::CenterNet::Loss.focal_loss(out[:heatmap], tgt[:heatmap])
            loss_sz = Vision::CenterNet::Loss.l1_loss(out[:size], tgt[:size], tgt[:mask])
            loss_of = Vision::CenterNet::Loss.l1_loss(out[:offset], tgt[:offset], tgt[:mask])
            loss_kp = Vision::CenterNet::Loss.l1_loss(out[:kpts], tgt[:kpts], tgt[:mask])

            loss = loss_hm + loss_sz + loss_of + loss_kp

            opt.zero_grad
            loss.backward
            opt.step

            total_loss += loss.item
            steps += 1
          end

          puts "Epoch #{epoch + 1}: loss=#{total_loss / steps}"
        end

        Torch.save(model.state_dict, "models/center_net_keypoints.pth")
      end
    end
  end
end
