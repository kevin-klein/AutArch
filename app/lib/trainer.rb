class Trainer
  DECAY_LR_AT = [80, 100]
  ITERATIONS = 120
  DECAY_LR_TO = 0.1
  LR = 1e-3
  MOMENTUM = 0.9  # momentum
  WEIGHT_DECAY = 5e-4  # weight decay

  def initialize
    @dataset = DfgDataset.new(Rails.root.join('pdfs', 'VOC2018'))
    @loader = Torch::Utils::Data::DataLoader.new(@dataset, batch_size: 8, shuffle: true, collate_fn: @dataset.method(:collate_fn))

    @model = Ssd300.new(@dataset.n_classes)
    @criterion = MultiBoxLoss.new(@model.priors_cxcy)

    load_checkpoint

    biases = []
    not_biases = []

    @model.named_parameters.each do |name, param|
      next unless param.requires_grad

      if name.end_with?('.bias')
        biases << param
      else
        not_biases << param
      end
    end


    @optimizer = Torch::Optim::SGD.new([{'params': biases, 'lr': 2 * LR}, {'params': not_biases}],
                                    lr: LR, momentum: MOMENTUM, weight_decay: WEIGHT_DECAY)

    # Calculate total number of epochs to train and the epochs to decay learning rate at (i.e. convert iterations to epochs)
    # To convert iterations to epochs, divide iterations by the number of iterations per epoch
    # The paper trains for 120,000 iterations with a batch size of 32, decays after 80,000 and 100,000 iterations
    @epochs = ITERATIONS / (@dataset.length / 32)
    @decay_lr_at = DECAY_LR_AT.map { |it| it / (@dataset.length / 32) }

    # decay_lr_at = [it / (train_dataset.length / 32) for it in DECAY_LR_AT]
  end

  def train
    ap @epochs
    (0...@epochs).each do |epoch|
      @epoch = epoch
      ::Utils.adjust_learning_rate(@optimizer, DECAY_LR_TO) if @decay_lr_at.include?(epoch)

      train_iteration

      data = {
        'epoch' => epoch,
        # optimizer: @optimizer.state_dict,
        'model' => @model.state_dict
      }
      Torch.save(data, 'rb-ssd.pth')
    end
  end

  def train_iteration
    # One epoch's training.
    # :param train_loader: DataLoader for training data
    # :param model: model
    # :param criterion: MultiBox loss
    # :param optimizer: optimizer
    # :param epoch: epoch number

    @model.train  # training mode enables dropout

    batch_time = AverageMeter.new  # forward prop. + back prop. time
    data_time = AverageMeter.new  # data loading time
    losses = AverageMeter.new  # loss

    start = Time.now.to_i

    # Batches
    @loader.each_with_index do |data, i|
      images, boxes, labels = data

      data_time.update(Time.now.to_i - start)

      # Forward prop.
      predicted_locs, predicted_scores = @model.call(images)  # (N, 8732, 4), (N, 8732, n_classes)

      # Loss
      loss = @criterion.call(predicted_locs, predicted_scores, boxes, labels)  # scalar

      # Backward prop.
      @optimizer.zero_grad
      loss.backward

      # Clip gradients, if necessary
      # ::Utils.clip_gradient(optimizer, grad_clip) unless grad_clip.nil?

      # Update model
      @optimizer.step

      # losses.update(loss.item, images.size(0))
      # batch_time.update(Time.now.to_i - start)

      # start = Time.now.to_i
      ap @epoch
      ap loss

      # Print status
      # if i % print_freq == 0:
      #     print('Epoch: [{0}][{1}/{2}]\t'
      #           'Batch Time {batch_time.val:.3f} ({batch_time.avg:.3f})\t'
      #           'Data Time {data_time.val:.3f} ({data_time.avg:.3f})\t'
      #           'Loss {loss.val:.4f} ({loss.avg:.4f})\t'.format(epoch, i, len(train_loader),
      #                                                           batch_time=batch_time,
      #                                                           data_time=data_time, loss=losses))
    end
  end

  def load_checkpoint

  end

  def to_str
    'trainer'
  end
end
