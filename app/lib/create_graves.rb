class CreateGraves
  def run(pages = nil)
    pages ||= Page.includes(:figures)

    pages.each do |page|
      figures = FigureMapConverter.convert_figures(page.figures)

      grave_figures = figures["Grave"]
      grave_figures&.each do |grave|
        next if grave.probability < 0.5
        handle_grave(grave, figures)
      end
    end
  end

  def handle_grave(grave, figures) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    figures = convert_figures(figures) unless figures.is_a?(Hash)
    non_grave_figures = figures.values.flatten.reject { |figure| figure.is_a?(Grave) }

    inside_grave = non_grave_figures.select { |figure| grave.collides?(figure) }

    find_closest_item(grave, figures["Scale"]) do |closest_scale|
      assign_grave_or_copy(closest_scale, grave)
    end

    find_closest_item(grave, figures["Arrow"]) do |closest_arrow|
      assign_grave_or_copy(closest_arrow, grave)
    end

    skeletons = inside_grave.select { |figure| figure.is_a?(SkeletonFigure) }
    skeletons.each { |skeleton| handle_skeleton(skeleton, grave) }

    goods = inside_grave.select { |figure| figure.is_a?(Good) }
    goods.each do |good|
      assign_grave_or_copy(good, grave)
    end

    find_closest_item(grave, figures["GraveCrossSection"]) do |cross|
      assign_grave_or_copy(cross, grave)
    end

    spines = inside_grave.select { |figure| figure.is_a?(Spine) }
    spines.each do |spine|
      spine.grave = grave
      spine.save!
    end

    skulls = inside_grave.select { |figure| figure.is_a?(Skull) }
    skulls.each do |skull|
      skull.grave = grave
      skull.save!
    end
  end

  def assign_grave_or_copy(figure, grave)
    figure = figure.dup if figure.parent_id.present? && figure.parent_id != grave.id
    figure.grave = grave
    figure.save!
  end

  def find_closest_item(grave, figures)
    return if figures.nil?

    figure_index = figures.map { |figure| grave.distance_to(figure) }.each_with_index.min[1]
    closest_figure = figures[figure_index]
    yield closest_figure
  end

  def handle_skeleton(skeleton, grave)
    skeleton.grave = grave
    skeleton.save!
  end
end
