class ExportLithics
  def export(lithics)
    lithics.map do |lithic|
      data = lithic.as_json(only: [:id, :contour])
      data[:meter_ratio] = lithic&.scale&.meter_ratio

      data
    end
  end
end
