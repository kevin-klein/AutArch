class AnalyzeScales
  def initialize

  end

  def analyze_scale(scale)
    image = ImageProcessing.extractFigure(scale.figure, scale.figure.page.image.data)
    contours = ImageProcessing.findContours(image)
    rects = contours.lazy.map { ImageProcessing.minAreaRect _1 }

    max_rect = rects.max_by { _1[:width] }
    width = max_rect[:width]

    ImageProcessing.imwrite('scale.jpg', image)
    t = RTesseract.new('scale.jpg', lang: 'eng')
    result = t.to_s.strip
    ap result

    cm_match = result.match(/^([0-9]+)cm$/)
    m_match = result.match(/^([0-9]+)m$/)

    distance = if cm_match
      cm_match.captures[0].to_f / 100
    elsif m_match
      m_match.captures[0].to_f
    else
      nil
    end

    return if distance.nil?

    ratio = distance / width
    scale.meter_ratio = ratio
    scale.save!
  end

  def run
    Scale.find_each do |scale|
      analyze_scale(scale)
    end
  end
end
