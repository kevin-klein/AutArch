class CreateLithics
  def run(pages = nil)
    pages ||= Page.includes(:figures)

    pages.each do |page|
      figures = FigureMapConverter.convert_figures(page.figures)

      lithic_figures = figures["StoneTool"]
      lithic_figures&.each do |lithic|
        next if lithic.probability < 0.3

        handle_lithic(lithic, figures)
      end
    end
  end

  def handle_lithic(lithic, figures)
    figures = convert_figures(figures) unless figures.is_a?(Hash)

    find_closest_item(lithic, figures["Scale"]) do |closest_scale|
      assign_lithic_or_copy(closest_scale, lithic)
    end

    LithicContours.new.create(lithic)
  end

  def assign_lithic_or_copy(figure, lithic)
    figure = figure.dup if figure.parent_id.present? && figure.parent_id != lithic.id
    figure.stone_tool = lithic
    figure.save!
  end

  def find_closest_item(lithic, figures)
    return if figures.nil?

    figure_index = figures.map { |figure| lithic.distance_to(figure) }.each_with_index.min[1]
    closest_figure = figures[figure_index]
    yield closest_figure
  end
end
