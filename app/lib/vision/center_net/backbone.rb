module Vision
  module CenterNet
    class Backbone < Torch::NN::Module
      attr_reader :out_channels, :downsample

      def initialize
        super
        @model = TorchVision::Models::ResNet50.new
        @model.instance_variable_set(:@fc, Torch::NN::Identity.new)
        @model.instance_variable_set(:@conv1, Torch::NN::Conv2d.new(1, 64, 7, stride: 2, padding: 3, bias: false))

        @out_channels = 2048
        @downsample = 32
      end

      def forward(x)
        @calls = [:@conv1, :@bn1, :@relu, :@maxpool, :@layer1, :@layer2, :@layer3, :@layer4]

        @calls.reduce(x) do |x, call|
          @model.instance_variable_get(call).call(x)
        end
      end
    end
  end
end
