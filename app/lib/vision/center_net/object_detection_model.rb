module Vision
  module CenterNet
    class ObjectDetectionModel < Torch::NN::Module
      def initialize(num_classes:, num_keypoints:)
        super()

        @backbone = Vision::CenterNet::Backbone.new

        @heatmap_head = Head.new(@backbone.out_channels, num_classes)
        @size_head = Head.new(@backbone.out_channels, 2)
        @offset_head = Head.new(@backbone.out_channels, 2)
      end

      def forward(images)
        feats = @backbone.call(images)

        {
          heatmap: Torch.sigmoid(@heatmap_head.call(feats)),
          size: @size_head.call(feats),
          offset: @offset_head.call(feats),
        }
      end
    end
  end
end
