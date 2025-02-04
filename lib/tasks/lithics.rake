namespace :export do
  task lithics: :environment do
    lithics = StoneTool
      # .includes(:scale)
      # .joins(:scale)
      .where(publication: Publication.find(32))
      .where(type: "StoneTool")
      # .filter { _1.scale&.meter_ratio.present? }
      .filter { !_1.contour.empty? }
    # .filter do |lithic|
    #   # ap lithic
    #   contour = lithic.size_normalized_contour
    #   if contour.empty?
    #     false
    #   else
    #     # rect = MinOpenCV.minAreaRect(contour)
    #     true
    #     # rect[:height] < 400
    #     # rect[:width] < 500 && rect[:height] < 500 && !contour.flatten.any? { _1 < 0 }
    #   end
    # end

    data = lithics.map do |lithic|
      {
        page: lithic.page.number + 1,
        coordinates: lithic.contour
      }
    end

    File.write(Rails.root.join("lithics.json").to_s, JSON.pretty_generate(data))
  end
end
