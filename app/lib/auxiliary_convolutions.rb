#based on: https://github.com/sgrvinod/a-PyTorch-Tutorial-to-Object-Detection

class AuxiliaryConvolutions # < Torch::NN::Module
  # include Torch::NN

  def initialize
    super

    @conv8_1 = Conv2d.new(1024, 256, 1, padding: 0)  # stride = 1, by default
    @conv8_2 = Conv2d.new(256, 512, 3, stride:2, padding: 1)  # dim. reduction because stride > 1

    @conv9_1 = Conv2d.new(512, 128, 1, padding: 0)
    @conv9_2 = Conv2d.new(128, 256, 3, stride: 2, padding: 1)  # dim. reduction because stride > 1

    @conv10_1 = Conv2d.new(256, 128, 1, padding: 0)
    @conv10_2 = Conv2d.new(128, 256, 3, padding: 0)  # dim. reduction because padding = 0

    @conv11_1 = Conv2d.new(256, 128, 1, padding: 0)
    @conv11_2 = Conv2d.new(128, 256, 3, padding: 0)  # dim. reduction because padding = 0

    # Initialize convolutions' parameters
    init_conv2d
  end

  def init_conv2d
    children.each do |child|
      if child.is_a?(Conv2d)
        Init.xavier_normal!(child.weight)
        Init.constant!(child.bias, 0.0)
      end
    end
  end

  def forward(conv7_feats)
    out = F.relu(@conv8_1.call(conv7_feats))  # (N, 256, 19, 19)
    out = F.relu(@conv8_2.call(out))  # (N, 512, 10, 10)
    conv8_2_feats = out  # (N, 512, 10, 10)

    out = F.relu(@conv9_1.call(out))  # (N, 128, 10, 10)
    out = F.relu(@conv9_2.call(out))  # (N, 256, 5, 5)
    conv9_2_feats = out  # (N, 256, 5, 5)

    out = F.relu(@conv10_1.call(out))  # (N, 128, 5, 5)
    out = F.relu(@conv10_2.call(out))  # (N, 256, 3, 3)
    conv10_2_feats = out  # (N, 256, 3, 3)

    out = F.relu(@conv11_1.call(out))  # (N, 128, 3, 3)
    conv11_2_feats = F.relu(@conv11_2.call(out))  # (N, 256, 1, 1)

    [conv8_2_feats, conv9_2_feats, conv10_2_feats, conv11_2_feats]
  end
end
