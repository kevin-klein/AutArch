module Vision
  class KeypointDataset
    attr_reader :keypoint_names, :num_keypoints, :kp_name_to_idx

    def initialize(json_path, image_dir, transform: nil, input_size: 256, heatmap_size: 64, max_persons_per_image: 1)
      @json_path = json_path
      @image_dir = image_dir
      @transform = transform
      @input_size = input_size
      @heatmap_size = heatmap_size
      @max_persons_per_image = max_persons_per_image

      @keypoint_names = CenterNet::PoseModel::KEYPOINT_NAMES
      @num_keypoints = CenterNet::PoseModel::NUM_KEYPOINTS
      @kp_name_to_idx = CenterNet::PoseModel::KP_NAME_TO_IDX

      @records = parse_labelstudio_json(json_path, image_dir)
      @samples = prepare_samples
    end

    def parse_labelstudio_json(json_path, image_dir)
      data = JSON.parse(File.read(json_path))
      records = []

      data.each do |item|
        file_upload = item["file_upload"] || ""
        filename = file_upload.include?("-") ? file_upload.split("-", 2)[1] : file_upload
        image_path = File.join(image_dir, filename)

        unless File.exist?(image_path)
          warn "WARNING: image not found: #{image_path} (skipping)"
          next
        end

        width = nil
        height = nil
        persons = []

        (item["annotations"] || []).each do |ann|
          kp_dict = {}

          (ann["result"] || []).each do |r|
            val = r["value"] || {}
            labels = val["keypointlabels"] || []
            next if labels.empty?

            x_pct = val["x"]
            y_pct = val["y"]
            next if x_pct.nil? || y_pct.nil?

            width ||= r["original_width"]
            height ||= r["original_height"]

            if width.nil? || height.nil?
              img = Vips::Image.new_from_file(image_path)
              width ||= img.width
              height ||= img.height
            end

            label = labels.first
            x_abs = x_pct.to_f / 100.0 * width.to_f
            y_abs = y_pct.to_f / 100.0 * height.to_f
            kp_dict[label] = [x_abs, y_abs]
          end

          persons << kp_dict unless kp_dict.empty?
        end

        if width.nil? || height.nil?
          img = Vips::Image.new_from_file(image_path)
          width = img.width
          height = img.height
        end

        records << {
          image_path: image_path,
          width: width.to_i,
          height: height.to_i,
          persons: persons
        }
      end

      records
    end

    def prepare_samples
      samples = []

      @records.each do |record|
        image_path = record[:image_path]
        width = record[:width]
        height = record[:height]

        # Process each person (or up to max_persons_per_image)
        record[:persons].take(@max_persons_per_image).each do |person_kps|
          # Create arrays for all keypoints
          keypoints = Array.new(@num_keypoints) { [nil, nil] }
          visibility = Array.new(@num_keypoints, 0)

          person_kps.each do |kp_name, (x_abs, y_abs)|
            idx = @kp_name_to_idx[kp_name]
            if idx
              # Convert to normalized coordinates
              x_norm = x_abs / width.to_f
              y_norm = y_abs / height.to_f
              keypoints[idx] = [x_norm, y_norm]
              visibility[idx] = 1
            end
          end

          samples << {
            image_path: image_path,
            width: width,
            height: height,
            keypoints: keypoints,
            visibility: visibility
          }
        end
      end

      samples
    end

    def [](index)
      sample = @samples[index]

      # Load and preprocess image
      img = Vips::Image.new_from_file(sample[:image_path])
      img = img.colourspace("srgb")

      # Resize to input size
      img = img.resize(@input_size.to_f / img.width, vscale: @input_size.to_f / img.height)

      # Convert to array and normalize to [0, 1]
      img_array = img.to_a
      img_tensor = Torch.tensor(img_array).permute(2, 0, 1).float / 255.0

      # Generate heatmaps
      heatmaps = generate_heatmaps(
        sample[:keypoints],
        sample[:visibility],
        size: [@heatmap_size, @heatmap_size]
      )

      {
        image: img_tensor,
        heatmaps: heatmaps,
        visibility: Torch.tensor(sample[:visibility], dtype: :float32),
        original_size: [sample[:width], sample[:height]],
        image_path: sample[:image_path]
      }
    end

    def size
      @samples.size
    end

    def length
      size
    end

    private

    def generate_heatmaps(keypoints, visibility, size: [64, 64])
      height, width = size
      heatmaps = Torch.zeros([@num_keypoints, height, width])

      @num_keypoints.times do |k|
        next unless visibility[k] == 1

        x_norm, y_norm = keypoints[k]
        next if x_norm.nil? || y_norm.nil?

        # Convert normalized coordinates to heatmap coordinates
        x_heatmap = (x_norm * (width - 1)).to_i
        y_heatmap = (y_norm * (height - 1)).to_i

        # Create Gaussian heatmap
        sigma = 2.0
        grid_y, grid_x = Torch.meshgrid(
          [Torch.arange(0, height, dtype: :float32), Torch.arange(0, width, dtype: :float32)]
        )

        heatmap = Torch.exp(-((grid_x - x_heatmap)**2 + (grid_y - y_heatmap)**2) / (2 * sigma**2))
        heatmaps[k] = heatmap
      end

      heatmaps
    end
  end
end
