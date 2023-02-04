class GraveSize
  def run(figures = nil)
    Figure.transaction do
      figures ||= Figure.includes({ page: :image })
      figures.each do |figure|
        next if figure.is_a?(Spine)

        dispatch_figure(figure)
      end
    end
  end

  def dispatch_figure(figure)
    if figure.is_a?(GraveCrossSection)
      handle_cross_section(figure)
    else
      handle_figure(figure)
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
      perimeter: stats[:perimeter],
      area: stats[:area],
      width: stats[:width],
      height: stats[:length]
    )
    figure.angle = stats[:angle] if figure.is_a?(Grave)

    figure.save!
  end
end
