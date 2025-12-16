module Vision
  module CenterNet
    class Head < Torch::NN::Module
      def initialize(in_channels, out_channels)
        super()
        @net = Torch::NN::Sequential.new(
          Torch::NN::Conv2d.new(in_channels, 256, 3, padding: 1),
          Torch::NN::ReLU.new,
          Torch::NN::Conv2d.new(256, out_channels, 1)
        )
      end

      def forward(x)
        @net.call(x)
      end
    end
  end
end
