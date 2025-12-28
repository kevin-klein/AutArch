module Vision
  module CenterNet
    class ResBlock < Torch::NN::Module
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
  end
end
