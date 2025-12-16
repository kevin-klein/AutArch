module Vision
  module CenterNet
    module Loss
      def self.focal_loss(pred, gt)
        pos = gt.eq(1)
        neg = gt.lt(1)
        neg_w = (1 - gt)**4

        pos_loss = -(pred.log * ((1 - pred)**2)) * pos
        neg_loss = -((1 - pred).log * (pred**2)) * neg_w * neg

        num_pos = pos.sum
        (num_pos > 0) ? (pos_loss.sum + neg_loss.sum) / num_pos : neg_loss.sum
      end

      def self.l1_loss(pred, gt, mask)
        Torch::NN::Functional.l1_loss(pred * mask, gt * mask, reduction: :sum) / (mask.sum + 1e-4)
      end
    end
  end
end
