module Vision
  KEYPOINT_NAMES = [
    "Head", "neck", "left shoulder", "right shoulder",
    "left elbow", "right elbow", "left wrist", "right wrist",
    "pelvic", "left hip", "right hip",
    "left knee", "right knee", "left ankle", "right ankle"
  ]
  NUM_KEYPOINTS = KEYPOINT_NAMES.length
  KP_NAME_TO_IDX = KEYPOINT_NAMES.each_with_index.to_h

  # ------------------------------------------------------------
  # CenterNet-Pose Dataset
  # ------------------------------------------------------------
  class KeypointDataset
    def self.parse_labelstudio_json(json_path, image_dir)
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

    def self.transforms
      @transforms ||= TorchVision::Transforms::Compose.new([
        TorchVision::Transforms::Resize.new([@input_size, @input_size]),
        TorchVision::Transforms::ToTensor.new
      ])
    end

    def initialize(records, input_size: 256, downsample: 8)
      @records = records
      @input_size = input_size
      @down = downsample
      @out_size = input_size / downsample
      @transforms = transforms
    end

    def length
      @records.length
    end

    def get_item(idx)
      rec = @records[idx]
      img = Vips::Image.new_from_file(rec[:image_path])
      img = img.colourspace("b-w")

      img_t = @transforms.call(img)

      # Targets
      heatmap = Torch.zeros(1, @out_size, @out_size)
      size = Torch.zeros(2, @out_size, @out_size)
      offset = Torch.zeros(2, @out_size, @out_size)
      kpts = Torch.zeros(NUM_KEYPOINTS * 2, @out_size, @out_size)
      mask = Torch.zeros(1, @out_size, @out_size)

      rec[:persons].each do |person|
        xs = []
        ys = []

        person.each do |_, (x, y)|
          xs << x * @input_size / rec[:width]
          ys << y * @input_size / rec[:height]
        end

        next if xs.empty?

        cx = xs.sum / xs.length
        cy = ys.sum / ys.length

        cx_ds = cx / @down
        cy_ds = cy / @down
        cx_i = cx_ds.floor
        cy_i = cy_ds.floor

        next if cx_i < 0 || cy_i < 0 || cx_i >= @out_size || cy_i >= @out_size

        heatmap[0, cy_i, cx_i] = 1.0
        offset[0, cy_i, cx_i] = cx_ds - cx_i
        offset[1, cy_i, cx_i] = cy_ds - cy_i
        mask[0, cy_i, cx_i] = 1.0

        w = xs.max - xs.min
        h = ys.max - ys.min
        size[0, cy_i, cx_i] = w / @down
        size[1, cy_i, cx_i] = h / @down

        person.each do |name, (x, y)|
          k = KP_NAME_TO_IDX[name]
          next if k.nil?
          kpts[2 * k, cy_i, cx_i] = (x * @input_size / rec[:width] - cx) / @down
          kpts[2 * k + 1, cy_i, cx_i] = (y * @input_size / rec[:height] - cy) / @down
        end
      end

      [img_t, {heatmap: heatmap, size: size, offset: offset, kpts: kpts, mask: mask}]
    end

    # ---- batching helper ----
    def get_batch(indices)
      imgs = []
      hms = []
      szs = []
      ofs = []
      kps = []
      mks = []

      indices.each do |i|
        img, tgt = get_item(i)
        imgs << img
        hms << tgt[:heatmap]
        szs << tgt[:size]
        ofs << tgt[:offset]
        kps << tgt[:kpts]
        mks << tgt[:mask]
      end

      [
        Torch.stack(imgs),
        {
          heatmap: Torch.stack(hms),
          size: Torch.stack(szs),
          offset: Torch.stack(ofs),
          kpts: Torch.stack(kps),
          mask: Torch.stack(mks)
        }
      ]
    end
  end
end
