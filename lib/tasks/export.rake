namespace :export do
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
end
