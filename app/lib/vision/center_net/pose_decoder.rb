module Vision
  module CenterNet
    class PoseDecoder
      def initialize(downsample:, num_keypoints:)
        @down = downsample
        @num_kpts = num_keypoints
      end

      def decode(heatmaps, image_width:, image_height:)
        b, k, hh, hw = heatmaps.shape
        flat = heatmaps.view(b, k, hh * hw)

        scores, indices = flat.max(dim: 2)

        ys = indices / hw
        xs = indices % hw

        xs = xs.to(dtype: :float) * (image_width.to_f / hw)
        ys = ys.to(dtype: :float) * (image_height.to_f / hh)

        Torch.stack([xs, ys], dim: 2)
      end
    end
  end
end
