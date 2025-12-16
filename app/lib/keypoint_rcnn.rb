class KeypointRcnn
  def initialize(model_path)
    # Load the TorchScript model exported from Python
    @device = Torch.device('cpu') # Change to 'cuda' if available
    @model = Torch::JIT.load(model_path)
    @model.to(@device)
    @model.eval
  end

  def detect(image_path, threshold: 0.7)
    # 1. Preprocess the image
    image_tensor = preprocess_image(image_path)

    # 2. Forward pass
    # R-CNN models expect a List[Tensor] as input
    inputs = [image_tensor.to(@device)]

    # Run inference (no_grad is cleaner for inference)
    outputs = Torch.no_grad do
      @model.forward(inputs)
    end

    # 3. Parse Output
    # The output is an Array of Hashes (one per input image)
    # Structure: [{'boxes' => ..., 'labels' => ..., 'scores' => ..., 'keypoints' => ...}]
    result = outputs[0]

    filter_results(result, threshold)
  end

  private

  def preprocess_image(path)
    # Load image using MiniMagick
    img = MiniMagick::Image.open(path)

    # Convert pixels to a generic array
    # Note: For high performance, consider using 'vips' or raw byte reading
    pixels = img.get_pixels

    # Convert to Tensor: [H, W, C] -> [C, H, W]
    # Normalize to 0-1 range (standard for PyTorch models)
    tensor = Torch.tensor(pixels).permute([2, 0, 1]).float.div(255.0)

    tensor
  end

  def filter_results(result, threshold)
    scores = result['scores']

    # Find indices where score > threshold
    # Note: Ruby torch binding syntax allows standard comparisons
    keep = scores.gt(threshold).nonzero.squeeze(1)

    return [] if keep.numel == 0

    # Extract relevant data
    boxes = result['boxes'].index_select(0, keep)
    keypoints = result['keypoints'].index_select(0, keep)
    final_scores = scores.index_select(0, keep)

    {
      boxes: boxes,
      keypoints: keypoints,
      scores: final_scores
    }
  end
end
