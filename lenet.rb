class LeNet < Torch::NN::Module
  include Torch::NN

  def initialize
    super

    @conv1 = Conv2d.new(1, 6, 3)
    @conv2 = Conv2d.new(6, 16, 3)

    @fc1 = Linear.new(6 * 6 * 16, 120)
    @fc2 = Linear.new(120, 84)
    @fc3 = Linear.new(84, 10)
  end

  def forward(x)
    x = F.max_pool2d(F.relu(@conv1.call(x)), [2, 2])
    x = F.max_pool2d(F.relu(@conv2.call(x)), 2)
    x = x.view(-1, num_flat_features(x))
    x = F.relu(@fc1.call(x))
    x = F.relu(@fc2.call(x))
    x = @fc3.call(x)
  end

  def num_flat_features(x)
    size = x.size.drop(1)
    num_features = 1
    size.each do |i|
      num_features *= i
    end
    num_features
  end
end

net = LeNet.new
ap net

input = Torch.rand(1, 1, 32, 32)
output = net.call(input)

ap output
