class GraveAngles
  def run(figures = nil)
    Arrow.transaction do
      figures ||= Arrow.includes({page: :image})
      figures.each do |arrow|
        arrow.angle = arrow_angle(arrow)
        arrow.save!
      end
    end
    nil
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
