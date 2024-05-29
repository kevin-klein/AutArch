class AnalyzeScales
  def analyze_scale(scale)
    return unless scale.is_a?(Scale)
    (1.0..2.0).step(0.25).each do |factor|
      assign_contour_width(scale, factor)
      break if scale.nil? || scale.width > 0
    end

    text = ""
    # (1.0..2.0).step(0.25).each do |factor|
    text = scale_text(scale)
    #   break unless text&.empty?
    # end
    distance, ratio = calculate_contour_ratio(scale, text)

    return if distance.nil?

    scale.meter_ratio = ratio
    scale.text = distance * 100
    scale.save!
  end

  def scale_text(scale)
    # test_scale = scale.dup
    # test_scale.x1 /= -factor
    # test_scale.y1 /= -factor
    # test_scale.x2 *= factor
    # test_scale.y2 *= factor

    ap "extract"
    image = ImageProcessing.extractFigure(scale, scale.page.image.data.download)
    return "" if image.size == 0

    ImageProcessing.imwrite("scale.jpg", image)
    t = RTesseract.new("scale.jpg", lang: "eng")
    result = t.to_s.strip
    result.tr("i", "1")
  end

  def calculate_contour_ratio(scale, text)
    return [nil, nil] if text.empty?
    cm_match = text.match(/([0-9]+)cm$/)
    m_match = text.match(/([0-9]+)m$/)

    distance = if cm_match
      cm_match.captures[0].to_f / 100
    elsif m_match
      m_match.captures[0].to_f
    end

    ratio = if scale.text.present?
      (scale.text.to_f / 100) / scale.width
    elsif distance.present?
      distance / scale.width
    end

    [distance, ratio]
  end

  def assign_contour_width(scale, factor)
    test_scale = scale.dup
    test_scale.x1 /= factor
    test_scale.y1 /= factor
    test_scale.x2 *= factor
    test_scale.y2 *= factor

    image = ImageProcessing.extractFigure(test_scale, scale.page.image.data.download)
    contours = ImageProcessing.findContours(image, "tree")
    rects = contours.map { ImageProcessing.minAreaRect _1 }

    return if rects.empty?

    max_rect = rects.max_by { [_1[:width], _1[:height]].max }
    width = [max_rect[:width], max_rect[:height]].max

    scale.width = width
    scale.save!
  end

  def run(scales = nil)
    scales ||= Scale.all
    Scale.transaction do
      scales.each do |scale|
        analyze_scale(scale)
      end
    end

    nil
  end
end
