class AnalyzeContour
  def run(figure)
    image = MinOpenCV.extractFigure(figure, figure.page.image.data)
    image = MinOpenCV.invert(image)

    # image = MinOpenCV.dilate(image, [4, 4])
    # image = MinOpenCV.erode(image, [2, 2])
    contours = MinOpenCV.findContours(image, "tree")
    contour = contours.max_by { MinOpenCV.contourArea _1 }

    if contour.present?
      figure.contour = contour
      figure.save!
    end

    figure
  end
end
