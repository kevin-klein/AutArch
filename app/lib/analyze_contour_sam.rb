class AnalyzeContourSam
  def run(figure)
    image = MinOpenCV.extractFigure(figure, figure.page.image.data)

    contour = segment(image)["contour"].flatten(1)
    figure.contour = contour
    figure.save!

    figure
  end

  def segment(image)
    io = StringIO.new(image)
    file = HTTP::FormData::File.new io, filename: "page.jpg"
    response = HTTP.post("#{ENV["ML_SERVICE_URL"]}/segment", form: {
      image: file
    })

    response.parse["predictions"]
  end
end
