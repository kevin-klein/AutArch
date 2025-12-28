module Vision
  module CenterNet
    class Flatten < Torch::NN::Module
      attr_reader :start_dim

      def initialize(start_dim:)
        super()

        @start_dim = start_dim
      end

      def forward(x)
        Torch.flatten(x, start_dim: @start_dim)
      end
    end
  end
end
