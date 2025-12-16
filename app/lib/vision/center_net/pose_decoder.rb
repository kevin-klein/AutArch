module Vision
  module CenterNet
    class PoseDecoder
      def initialize(downsample:, num_keypoints:, topk: 40)
        @down = downsample
        @num_kpts = num_keypoints
        @topk = topk
      end

      def decode(outputs)
        heat = outputs[:heatmap][0, 0]
        size = outputs[:size][0]
        off = outputs[:offset][0]
        kpts = outputs[:kpts][0]

        scores, inds = heat.flatten.topk(@topk)
        h, w = heat.shape

        detections = []

        inds.each_with_index do |ind, i|
          cy = (ind / w).to_i
          cx = (ind % w).to_i

          dx = off[0, cy, cx]
          dy = off[1, cy, cx]

          bw = size[0, cy, cx]
          bh = size[1, cy, cx]

          cx_i = (cx + dx) * @down
          cy_i = (cy + dy) * @down

          box = [
            cx_i - bw * @down / 2,
            cy_i - bh * @down / 2,
            cx_i + bw * @down / 2,
            cy_i + bh * @down / 2
          ]

          keypoints = []
          @num_kpts.times do |k|
            kdx = kpts[2 * k, cy, cx]
            kdy = kpts[2 * k + 1, cy, cx]
            keypoints << [cx_i + kdx * @down, cy_i + kdy * @down]
          end

          detections << {score: scores[i], box: box, keypoints: keypoints}
        end

        detections
      end
    end
  end
end
