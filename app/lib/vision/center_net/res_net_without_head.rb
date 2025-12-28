module Vision
  module CenterNet
    class ResNetWithoutHead < Torch::NN::Module
      def initialize(resnet)
        super()
        @resnet = resnet
        @resnet.instance_variable_set(:@avgpool, nil)
        @resnet.instance_variable_set(:@fc, nil)
      end

      def forward(x)
        layers = [
          :@conv1, :@bn1, :@relu, :@maxpool,
          :@layer1, :@layer2, :@layer3, :@layer4
        ]
        layers.reduce(x) { |x, layer| @resnet.instance_variable_get(layer).call(x) }
      end
    end
  end
end
