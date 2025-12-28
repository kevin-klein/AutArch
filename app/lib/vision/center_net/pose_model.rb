module Vision
  module CenterNet
    class BasicBlock < Torch::NN::Module
      def initialize(in_channels, out_channels, stride: 1)
        super()

        @conv1 = Torch::NN::Conv2d.new(in_channels, out_channels, 3,
                                      stride: stride, padding: 1, bias: false)
        @bn1 = Torch::NN::BatchNorm2d.new(out_channels)
        @relu = Torch::NN::ReLU.new
        @conv2 = Torch::NN::Conv2d.new(out_channels, out_channels, 3,
                                      stride: 1, padding: 1, bias: false)
        @bn2 = Torch::NN::BatchNorm2d.new(out_channels)

        # Skip connection if dimensions change
        @downsample = nil
        if stride != 1 || in_channels != out_channels
          @downsample = Torch::NN::Sequential.new(
            Torch::NN::Conv2d.new(in_channels, out_channels, 1,
                                stride: stride, bias: false),
            Torch::NN::BatchNorm2d.new(out_channels)
          )
        end
      end

      def forward(x)
        identity = x

        out = @conv1.call(x)
        out = @bn1.call(out)
        out = @relu.call(out)

        out = @conv2.call(out)
        out = @bn2.call(out)

        if @downsample
          identity = @downsample.call(x)
        end

        out += identity
        out = @relu.call(out)

        out
      end
    end

    class PoseModel < Torch::NN::Module
     KEYPOINT_NAMES = [
        "Head", "neck", "left shoulder", "right shoulder",
        "left elbow", "right elbow", "left wrist", "right wrist",
        "pelvic", "left hip", "right hip",
        "left knee", "right knee", "left ankle", "right ankle"
      ]
      NUM_KEYPOINTS = KEYPOINT_NAMES.length
      KP_NAME_TO_IDX = KEYPOINT_NAMES.each_with_index.to_h

      BACKBONE_CHANNELS = {
        'simple' => 256,
        'resnet18' => 512,
        'resnet101' => 2048
      }

      def initialize(backbone: 'resnet18', pretrained: false,
                    input_size: 256, heatmap_size: 64)
        super()

        @num_keypoints = NUM_KEYPOINTS
        @heatmap_size = heatmap_size
        @input_size = input_size

        # Backbone network - using a simpler CNN for torch.rb compatibility
        @backbone = create_backbone(backbone)
        backbone_channels = BACKBONE_CHANNELS[backbone]

        # Heatmap prediction head
        @heatmap_head = Torch::NN::Sequential.new(
          Torch::NN::Conv2d.new(backbone_channels, 256, 3, padding: 1),
          Torch::NN::BatchNorm2d.new(256),
          Torch::NN::ReLU.new,
          Torch::NN::Conv2d.new(256, 128, 3, padding: 1),
          Torch::NN::BatchNorm2d.new(128),
          Torch::NN::ReLU.new,
          Torch::NN::Conv2d.new(128, @num_keypoints, 1),
          Torch::NN::Sigmoid.new
        )

        # Visibility prediction head (for missing keypoints)
        @visibility_head = Torch::NN::Sequential.new(
          Torch::NN::AdaptiveAvgPool2d.new([1, 1]),
          Flatten.new(start_dim: 1),
          Torch::NN::Linear.new(backbone_channels, 256),
          Torch::NN::ReLU.new,
          Torch::NN::Dropout.new(p: 0.3),
          Torch::NN::Linear.new(256, @num_keypoints),
          Torch::NN::Sigmoid.new
        )
      end

      def create_backbone(backbone_type)
        case backbone_type
        when 'resnet50'
          model = TorchVision::Models::ResNet50.new
          ResNetWithoutHead.new(model)
        when 'resnet101'
          model = TorchVision::Models::ResNet101.new
          ResNetWithoutHead.new(model)
        when 'resnet152'
          model = TorchVision::Models::ResNet152.new
          ResNetWithoutHead.new(model)
        when 'resnet18'
          # Simplified ResNet-like backbone
          Torch::NN::Sequential.new(
            # Initial convolution
            Torch::NN::Conv2d.new(1, 64, 7, stride: 2, padding: 3),
            Torch::NN::BatchNorm2d.new(64),
            Torch::NN::ReLU.new,
            Torch::NN::MaxPool2d.new(3, stride: 2, padding: 1),

            # Layer 1
            ResBlock.new(64, 64, stride: 1),
            ResBlock.new(64, 64),

            # Layer 2
            ResBlock.new(64, 128, stride: 2),
            ResBlock.new(128, 128),

            # Layer 3
            ResBlock.new(128, 256, stride: 2),
            ResBlock.new(256, 256),

            # Layer 4
            ResBlock.new(256, 512, stride: 2),
            ResBlock.new(512, 512)
          )
        when 'simple'
          # Simple CNN backbone
          Torch::NN::Sequential.new(
            Torch::NN::Conv2d.new(1, 32, 3, padding: 1),
            Torch::NN::BatchNorm2d.new(32),
            Torch::NN::ReLU.new,
            Torch::NN::MaxPool2d.new(2, stride: 2),

            Torch::NN::Conv2d.new(32, 64, 3, padding: 1),
            Torch::NN::BatchNorm2d.new(64),
            Torch::NN::ReLU.new,
            Torch::NN::MaxPool2d.new(2, stride: 2),

            Torch::NN::Conv2d.new(64, 128, 3, padding: 1),
            Torch::NN::BatchNorm2d.new(128),
            Torch::NN::ReLU.new,
            Torch::NN::MaxPool2d.new(2, stride: 2),

            Torch::NN::Conv2d.new(128, 256, 3, padding: 1),
            Torch::NN::BatchNorm2d.new(256),
            Torch::NN::ReLU.new,
            Torch::NN::MaxPool2d.new(2, stride: 2)
          )
        else
          raise "Unsupported backbone: #{backbone_type}"
        end
      end

      def forward(x)
        # Extract features
        features = @backbone.call(x)

        # Predict heatmaps
        heatmaps = @heatmap_head.call(features)

        # Predict visibility probabilities
        visibility = @visibility_head.call(features)

        # Resize heatmaps to target size
        heatmaps = Torch::NN::Functional.interpolate(
          heatmaps,
          size: [@heatmap_size, @heatmap_size],
          mode: 'bilinear',
          align_corners: true
        )

        { heatmaps: heatmaps, visibility: visibility }
      end

      def predict_keypoints(x, threshold: 0.5)
        # Forward pass
        output = forward(x)
        heatmaps = output[:heatmaps]
        visibility = output[:visibility]

        batch_size = heatmaps.size(0)
        keypoints = []
        scores = []
        visibilities = []

        # Process each sample in batch
        batch_size.times do |b|
          sample_keypoints = []
          sample_scores = []
          sample_visibilities = []

          @num_keypoints.times do |k|
            heatmap = heatmaps[b, k]
            vis_prob = visibility[b, k].item

            # Only consider keypoint if visibility probability > threshold
            if vis_prob > threshold
              # Find peak in heatmap
              flat_index = heatmap.argmax.item
              height = heatmap.size(0)
              width = heatmap.size(1)

              y = flat_index / width
              x_pos = flat_index % width

              # Convert to normalized coordinates [0, 1]
              x_norm = x_pos.to_f / (width - 1)
              y_norm = y.to_f / (height - 1)

              # Get confidence score (peak value)
              confidence = heatmap[y, x_pos].item

              sample_keypoints << [x_norm, y_norm]
              sample_scores << confidence * vis_prob  # Combined score
            else
              # Keypoint is missing
              sample_keypoints << [nil, nil]
              sample_scores << 0.0
            end
            sample_visibilities << vis_prob
          end

          keypoints << sample_keypoints
          scores << sample_scores
          visibilities << sample_visibilities
        end

        {
          keypoints: keypoints,
          scores: scores,
          visibility: visibilities,
          keypoint_names: KEYPOINT_NAMES
        }
      end

      def format_predictions(results, original_width, original_height)
        formatted = []

        results[:keypoints].each_with_index do |person_kps, person_idx|
          person_pred = {}

          KEYPOINT_NAMES.each_with_index do |name, idx|
            kp = person_kps[idx]
            score = results[:scores][person_idx][idx]
            visibility = results[:visibility][person_idx][idx]

            if kp[0] && kp[1]
              # Convert normalized coordinates back to original image dimensions
              x_abs = kp[0] * original_width
              y_abs = kp[1] * original_height

              person_pred[name] = {
                x: x_abs,
                y: y_abs,
                score: score,
                visibility: visibility
              }
            else
              person_pred[name] = {
                x: nil,
                y: nil,
                score: 0.0,
                visibility: visibility
              }
            end
          end

          formatted << person_pred
        end

        formatted
      end
    end
  end
end
