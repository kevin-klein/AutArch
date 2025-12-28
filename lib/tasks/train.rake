namespace :train do
  task center_net_pose: :environment do
    model = Vision::CenterNet::PoseModel.new(
      backbone: 'resnet101',
      input_size: 256,
      heatmap_size: 64
    )
      # model.load_state_dict(Torch.load("models/center_net_keypoints.pth"))
    trainer = Vision::CenterNet::Trainer.new
    trainer.train(model, device: "cuda", epochs: 100, batch_size: 16)
  end
end
