class LithicContours
  def create(lithic)
    image = MinOpenCV.extractFigure(lithic, lithic.page.image.data)
    contours = MinOpenCV.findContours(image, "external")
    contours = filter_by_area(lithic, contours)

    lithic.contour = contours
    lithic.save!
  end

  def filter_by_area(lithic, contours)
    ContourTools.filter_by_area(lithic, contours, min_area: 0.01, max_area: 0.5)
  end

  # classifies a lithic into:
  # dorsal - front side
  # ventral - back side
  # platform - from the top
  # profile
  def classify_contours(lithic)
    # lithic.contour.map do |contour|

    # end
    # TODO: resnet
  end
end
