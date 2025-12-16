namespace :train do
  task center_net_pose: :environment do
    model = Vision::CenterNet::PoseModel.new(num_classes: 1, num_keypoints: 15)
    trainer = Vision::CenterNet::Trainer.new
    trainer.train(model, device: "cuda", epochs: 250, batch_size: 16)
  end
end
