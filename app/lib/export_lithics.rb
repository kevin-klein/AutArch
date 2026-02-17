class ExportLithics
  def export(lithics, num_points:, format:)
    lithics = lithics
    .filter do |lithic|
      lithic.contour.length > 0
    end
    .map do |lithic|
      data = lithic.as_json(only: [:id])
      data[:meter_ratio] = lithic&.scale&.meter_ratio
      data[:contour] = resample_polygon(select_largest_contour(lithic.contour), num_points)

      data
    end

    convert_to_format(lithics, format, num_points)
  end

  def convert_to_format(data, format, num_points)
    return data if format == 'json'

    csv_header = ['id', 'meter_ratio'] + (1..num_points).map { ["x#{_1}", "y_#{_1}"] }.flatten
    CSV.generate do |csv|
      csv << csv_header
      data.each do |lithic|
        csv << [lithic['id'], lithic[:meter_ratio]] + (lithic[:contour].flatten.map(&:to_i))
      end
    end
  end

  private

  def select_largest_contour(contours)
    return contours if contours[0][0].is_a?(Integer)

    contours.max_by { MinOpenCV.contourArea(_1) }
  end


  def resample_polygon(polygon, n_points)
    raise ArgumentError, "Need at least 2 points" if polygon.length < 2
    raise ArgumentError, "n_points must be >= 2" if n_points < 2

    # Ensure polygon is closed
    pts = polygon.dup
    pts << pts.first unless pts.first == pts.last

    # Compute cumulative edge lengths
    lengths = [0.0]
    total_length = 0.0

    (0...pts.length - 1).each do |i|
      dx = pts[i+1][0] - pts[i][0]
      dy = pts[i+1][1] - pts[i][1]
      seg_length = Math.sqrt(dx*dx + dy*dy)
      total_length += seg_length
      lengths << total_length
    end

    # Distance between resampled points
    step = total_length / n_points

    result = []
    current_edge = 0

    n_points.times do |i|
      target_dist = i * step

      # Move to correct edge
      while lengths[current_edge + 1] < target_dist
        current_edge += 1
      end

      # Interpolate along edge
      edge_start = pts[current_edge]
      edge_end   = pts[current_edge + 1]

      edge_length = lengths[current_edge + 1] - lengths[current_edge]
      edge_pos = target_dist - lengths[current_edge]
      t = edge_length.zero? ? 0.0 : edge_pos / edge_length

      x = edge_start[0] + t * (edge_end[0] - edge_start[0])
      y = edge_start[1] + t * (edge_end[1] - edge_start[1])

      result << [x.to_i, y.to_i]
    end

    result
  end
end
