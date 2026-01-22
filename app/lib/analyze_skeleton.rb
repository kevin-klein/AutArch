class AnalyzeSkeleton
  # @@model = Vision::CenterNet::PoseModel.new(
  #   backbone: 'resnet101',
  #   input_size: 256,
  #   heatmap_size: 64
  # )
  # @@model.load_state_dict(Torch.load("models/center_net_keypoints.pth"))
  # @@model.eval

  def run(skeleton)
  #   transforms = TorchVision::Transforms::Compose.new([
  #     TorchVision::Transforms::Resize.new([256, 256]),
  #     TorchVision::Transforms::ToTensor.new
  #   ])

  #   image_data = MinOpenCV.imencode(
  #     MinOpenCV.extractFigure(skeleton, skeleton.page.image.data)
  #   )
  #   image = Vips::Image.new_from_buffer(image_data, "")
  #   image = image.colourspace("srgb")
  #   input = transforms.call(image)

  #   result = @@model.predict_keypoints(Torch.stack([input]), threshold: 0.3)

  #   raise

  #   @@model.format_predictions(result, image.width, image.height)
  end
end
