# < Torch::Utils::Data::Dataset
class DfgDataset
  # include TorchVision::Transforms

  def initialize(folder, dataset: 'train.txt')
    @folder = folder
    @dataset = dataset
    @image_folder = File.join(@folder, 'JPEGImages')
    @annotations_folder = File.join(@folder, 'Annotations')
    @sets_folder = File.join(folder, 'ImageSets', 'Main')

    @data = File.read(File.join(@sets_folder, dataset)).split("\n")

    create_label_map
  end

  def length
    @data.length
  end

  def create_label_map
    @labels = @data.map do |file|
      annotations = load_annotations(file)
      annotations.css('object name').map(&:content)
    end.flatten.uniq.sort

    @label_map = @labels.map.with_index { |l, i| [l, i] }.to_h
  end

  def n_classes
    @label_map.keys.length
  end

  def load_annotations(file)
    File.open(File.join(@annotations_folder, "#{file}.xml")) do |f|
      Nokogiri::XML(f)
    end
  end

  def load_image(file)
    Vips::Image.new_from_file File.join(@image_folder, "#{file}.jpg")
  end

  def [](index)
    file_name = @data[index]
    image = load_image(file_name)

    annotations = load_annotations(file_name)

    labels = []
    boxes = []
    annotations.css('object').each do |object|
      labels << @label_map[object.at_css('name').content]
      bndbox = object.at_css('bndbox')
      boxes << [
        bndbox.at_css('xmin').content.to_i,
        bndbox.at_css('ymin').content.to_i,
        bndbox.at_css('xmax').content.to_i,
        bndbox.at_css('ymax').content.to_i
      ]
    end

    labels = Torch.tensor(labels)
    boxes = Torch.tensor(boxes)

    image, boxes, labels = ::Utils.transform(image, boxes, labels, split: @dataset)

    [image, boxes, labels]
  end

  def size
    length
  end

  def collate_fn(batch)
    # Since each image may have a different number of objects, we need a collate function (to be passed to the DataLoader).
    # This describes how to combine these tensors of different sizes. We use lists.
    # Note: this need not be defined in this Class, can be standalone.
    # :param batch: an iterable of N sets from __getitem__()
    # :return: a tensor of images, lists of varying-size tensors of bounding boxes, labels, and difficulties

    images = []
    boxes = []
    labels = []

    batch.each do |b|
      images << b[0]
      boxes << b[1]
      labels << b[2]
    end

    images = Torch.stack(images, dim: 0)

    [images, boxes, labels]  # tensor (N, 3, 300, 300), 3 lists of N tensors each
  end
end
