module Vision
  module CenterNet
    # class Backbone < Torch::NN::Module
    #   attr_reader :out_channels, :downsample

    #   def initialize
    #     super
    #     @model = TorchVision::Models::ResNet50.new
    #     @model.instance_variable_set(:@fc, Torch::NN::Identity.new)
    #     @model.instance_variable_set(:@conv1, Torch::NN::Conv2d.new(1, 64, 7, stride: 2, padding: 3, bias: false))
    #     @model.instance_variable_set(:@layer4, Torch::NN::Identity.new)

    #     @out_channels = 1024
    #     @downsample = 8
    #   end

    #   def forward(x)
    #     @calls = [:@conv1, :@bn1, :@relu, :@maxpool, :@layer1, :@layer2, :@layer3]

    #     @calls.reduce(x) do |x, call|
    #       @model.instance_variable_get(call).call(x)
    #     end
    #   end
    # end
    class Backbone < Torch::NN::Module
      attr_reader :out_channels, :downsample

      def initialize
        super
        @c1 = ConvBlock.new(1, 32, stride: 2)
        @c2 = ConvBlock.new(32, 64, stride: 2)
        @c3 = ConvBlock.new(64, 128, stride: 2)
        @c4 = ConvBlock.new(128, 256, stride: 2)

        @out_channels = 256
        @downsample = 16
      end

      def forward(x)
        x = @c1.call(x)
        x = @c2.call(x)
        x = @c3.call(x)
        x = @c4.call(x)
        x
      end
    end
  end
end
