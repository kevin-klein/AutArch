module ContourTools
  module_function

  def filter_by_area(figure, contours, min_area: 0.1, max_area: 0.6)
    area = figure.box_width * figure.box_height

    contours.filter do |contour|
      contour_area = MinOpenCV.contourArea(contour)

      (contour_area / area) > min_area && (contour_area / area) < max_area
    end
  end
end
