module Vision
  module CenterNet
    class ConvBlock < Torch::NN::Module
      def initialize(in_ch, out_ch, stride: 1)
        super()
        @conv = Torch::NN::Conv2d.new(in_ch, out_ch, 3, stride: stride, padding: 1, bias: false)
        @bn = Torch::NN::BatchNorm2d.new(out_ch)
        @relu = Torch::NN::ReLU.new(inplace: true)
      end

      def forward(x)
        @relu.call(@bn.call(@conv.call(x)))
      end
    end
  end
end
