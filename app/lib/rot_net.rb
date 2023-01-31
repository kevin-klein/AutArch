class RotNet < Torch::NN::Module
  NB_FILTERS = 64
  POOL_SIZE = [2, 2].freeze
  KERNEL_SIZE = [3, 3].freeze

  def initialize
    super
    @conv1 = Torch::NN::Conv2d.new(KERNEL_SIZE[0], NB_FILTERS, [1, KERNEL_SIZE[1]])
    @conv2 = Torch::NN::Conv2d.new(KERNEL_SIZE[0], NB_FILTERS, [1, KERNEL_SIZE[1]])
    @max_pool = Torch::NN::MaxPool2d.new([2, 2])
    @dropout = Torch::NN::Dropout.new(p: 0.25)
    @flatten = Torch::NN::Flatten.new
    @dense = Torch::NN::Linear.new(128)
    @dropout2 = Torch::NN::Dropout.new(p: 0.25)
    @dense2 = Torch::NN::Linear.new(360)
  end

  def forward(x) # rubocop:disable Naming/MethodParameterName, Metrics/AbcSize, Metrics/MethodLength
    x = Torch::NN::F.relu(x)
    x = @conv1.call(x)
    x = Torch::NN::F.relu(x)
    x = @conv2.call(x)
    x = Torch::NN::F.relu(x)
    x = @max_pool.call(x)
    x = @dropout.call(x)
    x = @flatten.call(x)
    x = Torch::NN::F.relu(x)
    x = @dense.call(x)
    x = @dropout2.call(x)
    x = Torch::NN::F.softmax(x)
    @dense2.call(x)
  end
end
