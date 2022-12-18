class AnalyzeScales
  def initialize

  end

  def analyze
    Scale.find_each do |scale|
      image = ImageProcessing.extractFigure(scale.figure, scale.figure.page.image.data)
      contours = ImageProcessing.findContours(image)
      rects = contours.lazy.map { ImageProcessing.minAreaRect _1 }

      max_rect = rects.max_by { _1[:width] }
      width = max_rect[:width]

      ImageProcessing.imwrite('scale.jpg', image)
      t = RTesseract.new('scale.jpg', lang: 'eng')
    end
  end
end
