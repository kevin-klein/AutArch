namespace :export do
  task lithics: :environment do
    lithics = StoneTool
      .includes(:scale)
      .joins(:scale)
      # .where("figures.probability > ?", 0.5)
      .where(publication: Publication.find(32))
      .where(type: "StoneTool")
      .filter { _1.scale&.meter_ratio.present? }
      .filter { !_1.contour.empty? }
      # .map(&:size_normalized_contour)
      .filter do |lithic|
        # ap lithic
        contour = lithic.size_normalized_contour
        if contour.empty?
          false
        else
          # rect = ImageProcessing.minAreaRect(contour)
          true
          # rect[:height] < 400
          # rect[:width] < 500 && rect[:height] < 500 && !contour.flatten.any? { _1 < 0 }
        end
      end

    data = lithics.map do |lithic|
      {
        page: lithic.page.number + 1,
        scaled_coordinates: lithic.size_normalized_contour,
        coordinates: lithic.contour
      }
    end

    File.write(Rails.root.join("lithics.json").to_s, JSON.pretty_generate(data))
  end
end
