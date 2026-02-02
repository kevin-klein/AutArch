class ExportLithics
  def export(lithics)
    lithics
    .filter do |lithic|
      lithic.contour.length > 0 && lithic.contour[0][0].is_a?(Integer)
    end
    .map do |lithic|
      data = lithic.as_json(only: [:id])
      data[:meter_ratio] = lithic&.scale&.meter_ratio
      data[:contour] = resample_polygon(lithic.contour, 100)

      data
    end
  end

   private

  def resample_polygon(polygon, num_points)
    return [] if polygon.empty? || num_points <= 0

    # Calculate the total length of the polygon
    total_length = 0.0
    (0...polygon.size - 1).each do |i|
      x0, y0 = polygon[i]
      x1, y1 = polygon[i + 1]
      total_length += Math.sqrt((x1 - x0)**2 + (y1 - y0)**2)
    end

    # If the polygon is closed, add the distance from last to first point
    if polygon.first == polygon.last
      x0, y0 = polygon[-2]
      x1, y1 = polygon[-1]
      total_length += Math.sqrt((x1 - x0)**2 + (y1 - y0)**2)
    end

    # Resample the polygon
    resampled = []
    step = total_length / (num_points - 1)
    current_length = 0.0
    current_index = 0

    (0...num_points).each do |i|
      target_length = i * step

      while current_index < polygon.size - 1 &&
            current_length + segment_length(polygon[current_index], polygon[current_index + 1]) < target_length
        current_length += segment_length(polygon[current_index], polygon[current_index + 1])
        current_index += 1
      end

      if current_index >= polygon.size - 1
        resampled << polygon.last
      else
        remaining = target_length - current_length
        ratio = remaining / segment_length(polygon[current_index], polygon[current_index + 1])
        resampled << interpolate(polygon[current_index], polygon[current_index + 1], ratio)
      end
    end

    resampled
  end

  def segment_length(point1, point2)
    x0, y0 = point1
    x1, y1 = point2
    Math.sqrt((x1 - x0)**2 + (y1 - y0)**2)
  end

  def interpolate(point1, point2, ratio)
    x0, y0 = point1
    x1, y1 = point2
    [x0 + (x1 - x0) * ratio, y0 + (y1 - y0) * ratio]
  end
end
