class GraveAngles
  def run(figures = nil)
    Arrow.transaction do
      figures ||= Arrow.includes({ page: :image })
      figures.each do |arrow|
        arrow.angle = 360 - (arrow_angle(arrow) % 360)
        arrow.save!
      end
    end
    nil
  end

  def arrow_angle(arrow)
    image = ImageProcessing.extractFigure(arrow, arrow.page.image.data)
    io = StringIO.new(image)
    file = HTTP::FormData::File.new io, filename: 'arrow.jpg'
    response = HTTP.post('http://localhost:8080/arrow', form: {
                           image: file
                         })

    response.parse['predictions']
  end
end
