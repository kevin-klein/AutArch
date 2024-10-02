namespace :export do
  task lithics: :environment do
    publication = Publication.find(32)

    CSV.open("lithics.csv", "w") do |csv|
      csv << ["Page", "total lithics", "false positives"]

      publication.pages.find_each do |page|
        csv << [page.number + 1, page.figures.where(type: "StoneTool").count, ""]
      end
    end
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
      image = ImageProcessing.extractFigure(skeleton, skeleton.page.image.data)
      ImageProcessing.imwrite(Rails.root.join("skeletons", "#{skeleton.id}.jpg").to_s, image)
    end
  end

  task arrows: :environment do
    Arrow.find_each do |arrow|
      # next if arrow.angle.nil?
      image = ImageProcessing.extractFigure(arrow, arrow.page.image.data)
      # image = ImageProcessing.rotateNoCutoff(image, -arrow.angle)

      ImageProcessing.imwrite(Rails.root.join("arrows", "#{arrow.id}.jpg").to_s, image)
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
      image = ImageProcessing.extractFigure(skeleton, skeleton.page.image.data.download)
      image = ImageProcessing.rotateNoCutoff(image, -spine.angle)

      ImageProcessing.imwrite(Rails.root.join("skeleton_angles", "#{skeleton.id}.jpg").to_s, image)
    rescue ActiveStorage::FileNotFoundError
    end
  end

  task all_skeletons: :environment do
    skeletons = SkeletonFigure
      .includes(:grave)
      .joins(:grave)

    skeletons.find_each do |skeleton|
      image = ImageProcessing.extractFigure(skeleton, skeleton.page.image.data.download)

      ImageProcessing.imwrite(Rails.root.join("keypoint_skeletons", "#{skeleton.id}.jpg").to_s, image)
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
          # rect = ImageProcessing.minAreaRect(contour)
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
