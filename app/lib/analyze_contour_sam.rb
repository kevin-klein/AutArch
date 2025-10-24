class AnalyzeContourSam
  def run(figure, points)
    image = MinOpenCV.extractFigure(figure, figure.page.image.data)

    contour = segment(image, points)["contour"]
    figure.contour = contour
    figure.save!

    figure
  end

  def segment(image, points)
    io = StringIO.new(image)
    file = HTTP::FormData::File.new io, filename: "page.jpg"
    response = HTTP.post("#{ENV["ML_SERVICE_URL"]}/segment", form: {
      image: file,
      points: points.to_json
    })

    response.parse["predictions"]
  end
end
