class GraveAngles
  def run(figures = nil)
    figures ||= Arrow.includes({ page: :image })
    Arrow.includes({ page: :image }).each do |arrow|
      image = ImageProcessing.extractFigure(arrow, arrow.page.image.data)
      contours = ImageProcessing.findContours(image, 'tree')

      next if contours.empty?

      rects = contours.lazy.map { ImageProcessing.minAreaRect _1 }

      index = rects.each_with_index.max_by do |r, _i|
        [r[:width], r[:height]].max
      end

      arrow_contour = contours[index[1]]

      distances = arrow_contour.map do |p1|
        arrow_contour.map do |p2|
          Math.sqrt(((p1[0] - p2[0])**2) + ((p1[1] - p2[1])**2))
        end
      end

      row, index1 = distances.each_with_index.max_by { |row, _index| row.max }
      dist, index2 = row.each_with_index.max_by { |d, _index| d }

      p1 = arrow_contour[index1]
      p2 = arrow_contour[index2]

      p1_distances = arrow_contour.map { |p2| Math.sqrt(((p1[0] - p2[0])**2) + ((p1[1] - p2[1])**2)) }.sum
      p2_distances = arrow_contour.map { |p1| Math.sqrt(((p1[0] - p2[0])**2) + ((p1[1] - p2[1])**2)) }.sum

      v1 = Vector[0, 1]
      v2 = Vector[(p1[0].to_f - p2[0].to_f).abs, (p1[1].to_f - p2[1].to_f).abs]

      next if v2.zero?

      arrow.angle = v1.angle_with(v2.normalize) * 57.29578

      arrow.angle = (arrow.angle + 180) % 360 if p1_distances > p2_distances
      arrow.save!
    end
  end
end
