class GraveSize
  def run(figures = nil)
    Figure.transaction do
      figures ||= Figure.includes({page: :image})
      figures.each do |figure|
        next if figure.is_a?(Spine)

        dispatch_figure(figure)
      end
    end

    nil
  end

  def dispatch_figure(figure)
    if figure.is_a?(GraveCrossSection)
      handle_cross_section(figure)
    else
      handle_figure(figure)
    end
  end

  def handle_cross_section(figure)
    if figure.manual_bounding_box
      figure.width = figure.bounding_box_width
      figure.height = figure.bounding_box_height
    else
      image = MinOpenCV.extractFigure(figure, figure.page.image.data)
      image = MinOpenCV.invert(image)
      contours = MinOpenCV.findContours(image, "tree")
      contour = contours.max_by { MinOpenCV.contourArea _1 }
      return if contour.nil?
      rect = MinOpenCV.boundingRect(contour)
      return if rect == -1

      figure.contour = contour.map { |x, y| [x, y] }
      figure.width = rect[:width]
      figure.height = rect[:height]
    end
    figure.save!
  end

  def handle_figure(figure)
    stats = grave_stats(figure, figure.page.image.data)
    return if stats.nil?
    figure.assign_attributes(
      perimeter: stats[:perimeter],
      area: stats[:area],
      width: stats[:width],
      height: stats[:height],
      contour: stats[:contour].map { |x, y| [x, y] }
    )
    figure.angle = stats[:angle] if figure.is_a?(Grave)
    figure.save!
  end

  def grave_stats(figure, image)
    if figure.manual_bounding_box
      manual_stats(figure, image)
    else
      contour_stats(figure, image)
    end
  end

  def manual_stats(figure, image)
    contour = figure.manual_contour
    if contour.nil? || contour.empty?
      {contour: [], perimeter: 0, area: 0, width: 0, height: 0, angle: 0}
    else
      arc = MinOpenCV.arcLength(contour)
      area = MinOpenCV.contourArea(contour)
      rect = MinOpenCV.minAreaRect(contour)
      {contour: contour, perimeter: arc, area: area, width: rect[:width], height: rect[:height], angle: rect[:angle]}
    end
  end

  def existing_contour_stats(figure)
    contour = figure.contour
    if contour.nil? || contour.empty?
      nil
    else
      rect = MinOpenCV.minAreaRect(contour.flatten(1))

      figure.assign_attributes(
        width: rect[:width],
        height: rect[:height]
      )
      figure.save!
    end
  end

  def contour_stats(figure, image)
    image = MinOpenCV.extractFigure(figure, image)
    image = MinOpenCV.invert(image)
    MinOpenCV.imwrite("test.png", image)
    contours = MinOpenCV.findContours(image, "tree")
    contour = contours.max_by { MinOpenCV.contourArea _1 }
    if contour.nil? || contour.empty?
      {contour: [], perimeter: 0, area: 0, width: 0, height: 0, angle: 0}
    else
      arc = MinOpenCV.arcLength(contour)
      area = MinOpenCV.contourArea(contour)
      rect = MinOpenCV.minAreaRect(contour)
      {contour: contour, perimeter: arc, area: area, width: rect[:width], height: rect[:height], angle: rect[:angle]}
    end
  end
end
