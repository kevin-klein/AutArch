namespace :ai do
  task center_net_pose: :environment do
    model = Vision::CenterNet::PoseModel.new(num_classes: 1, num_keypoints: 15)
    model.load_state_dict(Torch.load("models/center_net_keypoints.pth"))
    model.eval

    transforms = TorchVision::Transforms::Compose.new([
      TorchVision::Transforms::Resize.new([256, 256]),
      TorchVision::Transforms::ToTensor.new
    ])

    image = Vips::Image.new_from_file("training_data/skeleton_keypoint_images/1.jpg")
    input = transforms.call(image)

    result = model.call(Torch.stack([input]))

    decoder = Vision::CenterNet::PoseDecoder.new(downsample: 32, num_keypoints: 15, topk: 1)
    ap decoder.decode(result)
  end
end
