class GraveSize
  def run
    Figure.includes({ page: :image }).find_each do |figure|
      next if figure.is_a?(Spine)
      if figure.is_a?(GraveCrossSection)
        stats = ImageProcessing.getCrossSectionStats(figure, figure.page.image.data)
        figure.width = stats[:width]
        figure.height = stats[:height]
        figure.save!
      else
        stats = ImageProcessing.getGraveStats(figure, figure.page.image.data)
        figure.perimeter = stats[:arc]
        figure.area = stats[:area]
        figure.width = stats[:width]
        figure.height = stats[:height]
        figure.save!
      end
    end
  end
end
