class GraveAngles
  def run(figures = nil)
    Arrow.transaction do
      figures ||= Arrow.includes({page: :image})
      figures.each do |arrow|
        prediction_result = arrow_angle(arrow)
        ap prediction_result
        ap convert_result(prediction_result)
        # arrow.angle =
        # arrow.save!
      end
    end
    nil
  end

  def convert_domain(value)
    value.clamp(-1, 1)
  end

  def convert_acos_result(value)
    (value / Math::PI) * 360
  end

  def convert_result(result)
    cos, sin = result

    Math.atan2(sin, cos) * (180.0 / Math::PI)
  end

  def arrow_angle(arrow)
    image = ImageProcessing.extractFigure(arrow, arrow.page.image.data.download)
    io = StringIO.new(image)
    file = HTTP::FormData::File.new io, filename: "arrow.jpg"
    response = HTTP.post("http://127.0.0.1:8080/arrow", form: {
      image: file
    })

    response.parse["predictions"]
  end
end
