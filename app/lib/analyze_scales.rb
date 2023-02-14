class AnalyzeScales
  def analyze_scale(scale)
    assign_contour_width(scale)
    text = scale_text(scale)
    distance, ratio = calculate_contour_ratio(scale, text)

    return if distance.nil?

    scale.meter_ratio = ratio
    scale.text = distance * 100
    scale.save!
  end

  def scale_text(scale)
    image = ImageProcessing.extractFigure(scale, scale.page.image.data)
    ImageProcessing.imwrite('scale.jpg', image)
    t = RTesseract.new('scale.jpg', lang: 'eng')
    result = t.to_s.strip
    result.gsub('i', '1')
  end

  def calculate_contour_ratio(scale, text)
    cm_match = text.match(/^([0-9]+)cm$/)
    m_match = text.match(/^([0-9]+)m$/)

    distance = if cm_match
                 cm_match.captures[0].to_f / 100
               elsif m_match
                 m_match.captures[0].to_f
               end

    ratio = distance / scale.width
    [distance, ratio]
  end

  def assign_contour_width(scale)
    image = ImageProcessing.extractFigure(scale, scale.page.image.data)
    contours = ImageProcessing.findContours(image)
    rects = contours.lazy.map { ImageProcessing.minAreaRect _1 }

    max_rect = rects.max_by { _1[:width] }
    width = max_rect[:width]

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
  end
end
