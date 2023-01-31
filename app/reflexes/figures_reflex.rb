class FiguresReflex < ApplicationReflex
  def create
    grave_id = element.dataset['grave-id']
    @grave = Grave.find(grave_id)
    arrow = Arrow.new(
      x1: 100,
      y1: 100,
      y2: 200,
      x2: 200
    )
    figures = @grave.figures + [arrow]
    Rails.logger.debug figures
    html = render(partial: 'figures/figure_view', locals: { figures: figures, image: @grave.page.image })
    # html = 'some random text'
    morph '#figure-view', html
  end
end
