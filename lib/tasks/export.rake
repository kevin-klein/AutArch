namespace :export do
  def global_contour(figure)
    if figure.manual_bounding_box
      figure.contour.flatten
    elsif figure.instance_of?(StoneTool)
      (figure.contour.first + [figure.contour.first[0]]).map do |point|
        [point[0] + figure.x1, point[1] + figure.y1]
      end.flatten
    else
      (figure.contour + [figure.contour[0]]).map do |point|
        [point[0] + figure.x1, point[1] + figure.y1]
      end.flatten
    end
  end

  task :page, [:page_id] => :environment do |_, args|
    page_id = args[:page_id]
    page = Page.find(page_id)

    objects = page.figures.filter { _1.probability > 0.6 && !_1.contour.empty? && ["Grave", "Scale", "Arrow", "Ceramic"].include?(_1.type) }

    data = objects.map do |figure|
      figure_json = if figure.is_a?(Grave)
        figure.as_json(methods: [:width_with_unit, :height_with_unit])
      else
        figure.as_json
      end

      {
        id: figure.id,
        figure: figure_json,
        contour: global_contour(figure)
      }
    end

    File.write(Rails.root.join("page_#{page_id}.json").to_s, JSON.pretty_generate(data))
  end

  task masks: :environment do
    require "rvg/rvg"

    def mask_path(image, figure)
      Pathname.new("/mnt/g/masks/#{image.id}_#{figure.id}_mask.jpg")
    end

    def bounding_boxes(figures)
      figures.map do |figure|
        contour = global_contour(figure)

        MinOpenCV.boundingRect(contour.each_slice(2).to_a)
      end
    end

    def create_mask(image, figure)
      magick_image = Vips::Image.new_from_file(image.file_path)
      width, height = magick_image.size

      rvg = Magick::RVG.new(width, height) do |canvas|
        canvas.background_fill = "black"

        polygon = global_contour(figure)

        canvas.polygon(polygon).styles(fill: "white")
      end
      rvg.draw.write(mask_path(image, figure))
      true
    rescue Magick::ImageMagickError => e
      ap e
      false
    end

    def export_page(page)
      figures = page.figures.filter { _1.probability > 0.6 && !_1.contour.empty? && ["Grave", "Scale", "Arrow", "Ceramic"].include?(_1.type) }

      path = page.image.file_path
      if File.exist?(path) && figures.size > 0
        target_path = Pathname.new("/mnt/g/masks/#{page.image.id}.jpg")
        FileUtils.cp(path, target_path)

        boxes = bounding_boxes(figures)
        labels = figures.map(&:type)

        data = figures.zip(boxes, labels).filter_map do |figure, box, label|
          if create_mask(page.image, figure)
            [figure, box, label, mask_path(page.image, figure).basename]
          end
        end

        if !data.empty?
          File.open("/mnt/g/masks/#{page.image.id}.json", "w") do |f|
            masks = data.map { _1[3] }
            labels = data.map { _1[2] }
            boxes = data.map { _1[1] }

            data = {
              image: target_path.basename,
              masks: masks,
              bounding_boxes: boxes,
              labels: labels
            }
            f.write(JSON.pretty_generate(data))
          end
        else
          File.delete(target_path)
        end
      end
    end

    page_ids = Grave.all.filter do |grave|
      grave.width_with_unit[:unit] != "px" && grave.height_with_unit[:unit] != "px"
    end.map { _1.page_id }.uniq

    pages = Page.includes(:figures, :image).find(page_ids)

    Parallel.map(pages, in_processes: 8, progress: "Exporting pages") do |page|
      export_page(page)
    end
  end

  task lithics: :environment do
    publication = Publication.find(32)

    CSV.open("lithics.csv", "w") do |csv|
      csv << ["Page", "total lithics", "false positives"]

      publication.pages.find_each do |page|
        csv << [page.number + 1, page.figures.where(type: "StoneTool").count, ""]
      end
    end
  end

  task :orientations, [:tag_id] => :environment do |t, args|
    tag_id = args[:tag_id]
    @skeleton_angles = Site.includes(
      graves: [:spines, :arrow]
    ).all.to_a.map do |site|
      # 3 = corded ware
      # 2 = bell beaker

      spines = site.graves.joins(:tags).where(tags: {id: tag_id}).flat_map do |grave|
        grave.spines
      end

      angles = Stats.all_spine_angles(spines).to_a
      angles
    end.filter do |grave_data|
      grave_data.sum > 0
    end.flatten

    File.write("orientations-#{Tag.find(tag_id).name}.json", @skeleton_angles.to_json)
  end

  task spines: :environment do
    CSV.open("spines.csv", "w") do |csv|
      csv << %w[ID Angle]
      Spine.find_each do |spine|
        grave = spine.grave
        arrow = grave.arrow
        angle = spine.angle_with_arrow(arrow)
        csv << [grave.id, angle]
      end
    end
  end

  task db: :environment do
    models = [
      Publication,
      Page,
      Figure,
      Image
    ]

    models.each do |model|
      data = []
      model.find_each do |item|
        data << item.attributes.as_json
      end

      msg_pack_data = data.to_msgpack
      File.binwrite("#{model.table_name}.msgpack", msg_pack_data)
    end
  end

  task skeletons: :environment do
    SkeletonFigure.find_each do |skeleton|
      image = MinOpenCV.extractFigure(skeleton, skeleton.page.image.data)
      MinOpenCV.imwrite(Rails.root.join("skeletons", "#{skeleton.id}.jpg").to_s, image)
    end
  end

  task arrows: :environment do
    Arrow.find_each do |arrow|
      # next if arrow.angle.nil?
      image = MinOpenCV.extractFigure(arrow, arrow.page.image.data)
      # image = MinOpenCV.rotateNoCutoff(image, -arrow.angle)

      MinOpenCV.imwrite(Rails.root.join("arrows", "#{arrow.id}.jpg").to_s, image)
    end
  end

  task skeleton_images: :environment do
    skeletons = SkeletonFigure
      .includes(:grave)
      .joins(:grave)
    # .where("figures.probability > ?", 0.6)

    skeletons.find_each do |skeleton|
      spine = skeletonbash.grave.spines.first
      next if spine.nil?
      image = MinOpenCV.extractFigure(skeleton, skeleton.page.image.data)
      image = MinOpenCV.rotateNoCutoff(image, -spine.angle)

      MinOpenCV.imwrite(Rails.root.join("skeleton_angles", "#{skeleton.id}.jpg").to_s, image)
    rescue ActiveStorage::FileNotFoundError
    end
  end

  task all_skeletons: :environment do
    skeletons = SkeletonFigure
      .includes(:grave)
      .joins(:grave)

    skeletons.find_each do |skeleton|
      image = MinOpenCV.extractFigure(skeleton, skeleton.page.image.data)

      MinOpenCV.imwrite(Rails.root.join("keypoint_skeletons", "#{skeleton.id}.jpg").to_s, image)
    rescue ActiveStorage::FileNotFoundError
    end
  end

  task graves: :environment do
    graves = Grave
      .includes(:scale)
      # .joins(:scale)
      .joins(:arrow)
      .where("figures.probability > ?", 0.6)
      .where(publication_id: [
        # (52..75).to_a
        6,
        4,
        2,
        1
      ])
      .where(type: "Grave")
      .filter { _1.scale&.meter_ratio.present? || _1.percentage_scale.present? }
      .filter { !_1.contour.empty? }
      # .map(&:size_normalized_contour)
      .filter do |grave|
        # ap lithic
        contour = grave.size_normalized_contour
        if contour.empty?
          false
        else
          # rect = MinOpenCV.minAreaRect(contour)
          true
          # rect[:height] < 400
          # rect[:width] < 500 && rect[:height] < 500 && !contour.flatten.any? { _1 < 0 }
        end
      end

    sites = {
      6 => "Vlineves",
      4 => "Mondelange",
      2 => "Vikletice",
      1 => "Vlineves"
    }

    cultures = {
      6 => "BB",
      4 => "BB",
      2 => "CW",
      1 => "CW"
    }

    data = graves.map do |grave|
      {
        id: grave.identifier,
        page: grave.page.number + 1,
        scaled_coordinates: grave.size_normalized_contour,
        coordinates: grave.contour,
        site: sites[grave.publication.id],
        culture_label: cultures[grave.publication.id]
      }
    end

    ap data.count

    File.write(Rails.root.join("graves.json").to_s, JSON.pretty_generate(data))
  end
end
