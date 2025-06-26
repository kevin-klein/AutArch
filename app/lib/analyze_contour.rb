class AnalyzeContour
  def run(figure)
    image = MinOpenCV.extractFigure(figure, figure.page.image.data)
    image = MinOpenCV.invert(image)

    image = MinOpenCV.dilate(image, [6, 6])
    image = MinOpenCV.erode(image, [2, 2])
    MinOpenCV.imwrite("test.png", image)
    contours = MinOpenCV.findContours(image, "tree")
    contour = contours.max_by { MinOpenCV.contourArea _1 }

    if contour.present?
      figure.contour = contour
      figure.save!
    end

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
