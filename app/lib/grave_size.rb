class GraveSize
  def run
    Figure.includes({ page: :image }).find_each do |figure|
      next if figure.is_a?(Spine)

      if figure.is_a?(GraveCrossSection)
        handle_cross_section(figure)
      else
        handle_figure(figure)
      end
    end
  end

  def handle_cross_section(figure)
    stats = ImageProcessing.getCrossSectionStats(figure, figure.page.image.data)
    figure.width = stats[:width]
    figure.height = stats[:height]
    figure.save!
  end

  def handle_figure(figure)
    stats = ImageProcessing.getGraveStats(figure, figure.page.image.data)
    figure.assign_attributes(
      perimeter: stats[:arc],
      area: stats[:area],
      width: stats[:width],
      height: stats[:height]
    )
    figure.save!
  end
end
