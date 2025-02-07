class GraveAngles
  def run(figures = nil)
    Arrow.transaction do
      figures ||= Arrow.includes({page: :image})
      figures.each do |arrow|
        prediction_result = arrow_angle(arrow)
        cos, sin = prediction_result
        arrow.angle = GraveAngles.convert_angle_result(cos: cos, sin: sin)
        arrow.save!
      end
    end
    nil
  end

  def self.convert_angle_result(cos:, sin:)
    result = Math.atan2(sin, cos) * (180.0 / Math::PI)

    if result < 0
      result.abs
    else
      -result % 360
    end
  end

  def arrow_angle(arrow)
    image = MinOpenCV.extractFigure(arrow, arrow.page.image.data)
    io = StringIO.new(image)
    file = HTTP::FormData::File.new io, filename: "arrow.jpg"
    response = HTTP.post("#{ENV["ML_SERVICE_URL"]}/arrow", form: {
      image: file
    })

    response.parse["predictions"]
  end
end
