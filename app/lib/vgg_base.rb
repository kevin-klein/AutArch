#based on: https://github.com/sgrvinod/a-PyTorch-Tutorial-to-Object-Detection

class VggBase #< Torch::NN::Module
  # include Torch::NN

  def initialize
    super

    @conv1_1 = Conv2d.new(3, 64, 3, padding: 1)
    @conv1_2 = Conv2d.new(64, 64, 3, padding: 1)

    @pool1 = MaxPool2d.new(2, stride: 2)

    @conv2_1 = Conv2d.new(64, 128, 3, padding: 1)
    @conv2_2 = Conv2d.new(128, 128, 3, padding: 1)
    @pool2 = MaxPool2d.new(2, stride: 2)

    @conv3_1 = Conv2d.new(128, 256, 3, padding: 1)
    @conv3_2 = Conv2d.new(256, 256, 3, padding: 1)
    @conv3_3 = Conv2d.new(256, 256, 3, padding: 1)
    @pool3 = MaxPool2d.new(2, stride: 2, ceil_mode: true)  # ceiling (not floor) here for even dims

    @conv4_1 = Conv2d.new(256, 512, 3, padding: 1)
    @conv4_2 = Conv2d.new(512, 512, 3, padding: 1)
    @conv4_3 = Conv2d.new(512, 512, 3, padding: 1)
    @pool4 = MaxPool2d.new(2, stride: 2)

    @conv5_1 = Conv2d.new(512, 512, 3, padding: 1)
    @conv5_2 = Conv2d.new(512, 512, 3, padding: 1)
    @conv5_3 = Conv2d.new(512, 512, 3, padding: 1)
    @pool5 = MaxPool2d.new(3, stride:1, padding: 1)  # retains size because stride is 1 (and padding)

    # Replacements for FC6 and FC7 in VGG16
    @conv6 = Conv2d.new(512, 1024, 3, padding: 6, dilation: 6)  # atrous convolution

    @conv7 = Conv2d.new(1024, 1024, 1)

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

  def forward(image)
    out = F.relu(@conv1_1.call(image))  # (N, 64, 300, 300)
    out = F.relu(@conv1_2.call(out))  # (N, 64, 300, 300)
    out = @pool1.call(out)  # (N, 64, 150, 150)

    out = F.relu(@conv2_1.call(out))  # (N, 128, 150, 150)
    out = F.relu(@conv2_2.call(out))  # (N, 128, 150, 150)
    out = @pool2.call(out)  # (N, 128, 75, 75)

    out = F.relu(@conv3_1.call(out))  # (N, 256, 75, 75)
    out = F.relu(@conv3_2.call(out))  # (N, 256, 75, 75)
    out = F.relu(@conv3_3.call(out))  # (N, 256, 75, 75)
    out = @pool3.call(out)  # (N, 256, 38, 38), it would have been 37 if not for ceil_mode = True

    out = F.relu(@conv4_1.call(out))  # (N, 512, 38, 38)
    out = F.relu(@conv4_2.call(out))  # (N, 512, 38, 38)
    out = F.relu(@conv4_3.call(out))  # (N, 512, 38, 38)
    conv4_3_feats = out  # (N, 512, 38, 38)
    out = @pool4.call(out)  # (N, 512, 19, 19)

    out = F.relu(@conv5_1.call(out))  # (N, 512, 19, 19)
    out = F.relu(@conv5_2.call(out))  # (N, 512, 19, 19)
    out = F.relu(@conv5_3.call(out))  # (N, 512, 19, 19)
    out = @pool5.call(out)  # (N, 512, 19, 19), pool5 does not reduce dimensions

    out = F.relu(@conv6.call(out))  # (N, 1024, 19, 19)

    conv7_feats = F.relu(@conv7.call(out))  # (N, 1024, 19, 19)

    # Lower-level feature maps
    [conv4_3_feats, conv7_feats]
  end
end
