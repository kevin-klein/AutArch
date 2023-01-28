class CreateGraves

  def initialize

  end

  def run
    Page.includes(:figures).find_each do |page|
      figures = convert_figures(page.figures)

      grave_figures = figures['Grave']
      grave_figures&.each do |grave|
        handle_grave(grave, figures)
      end
    end
  end

  def convert_figures(figures)
    result = {}

    figures.each do |figure|
      arr = result[figure.type]
      arr ||= []
      arr << figure
      result[figure.type] = arr
    end

    result
  end

  def handle_grave(grave, figures)
    figures = convert_figures(figures) if !figures.is_a?(Hash)
    non_grave_figures = figures.values.flatten.select { |figure| !figure.is_a?(Grave) }

    inside_grave = non_grave_figures.select { |figure| grave.collides?(figure) }

    find_closest_item(grave, figures['Scale']) do |closest_scale|
      assign_grave_or_copy(closest_scale, grave)
    end

    find_closest_item(grave, figures['Arrow']) do |closest_arrow|
      assign_grave_or_copy(closest_arrow, grave)
    end

    skeletons = inside_grave.select { |figure| figure.is_a?(SkeletonFigure) }
    skeletons.each { |skeleton| handle_skeleton(skeleton, grave, figures) }

    goods = inside_grave.select { |figure| figure.is_a?(Good) }
    goods.each do |good|
      assign_grave_or_copy(good, grave)
    end

    find_closest_item(grave, figures['GraveCrossSection']) do |cross|

    end

    spines = inside_grave.select { |figure| figure.is_a?(Spine) }
    spines.each do |spine|
      spine.grave = grave
      spine.save!
    end
  end

  def assign_grave_or_copy(figure, grave)
    if figure.parent_id.present? && figure.parent_id != grave.id
      figure = figure.dup
      figure.grave = grave
      figure.save!
    else
      figure.grave = grave
      figure.save!
    end
  end

  def find_closest_item(grave, figures)
    return if figures.nil?

    figure_index = figures.map { |figure| grave.distance_to(figure) }.each_with_index.min[1]
    closest_figure = figures[figure_index]
    yield closest_figure
  end

  def handle_skeleton(skeleton, grave, figures)
    skeleton.grave = grave
    skeleton.save!

    skulls = figures['Skull']
    if skulls.present?
      skull_index = skulls.map { |figure| grave.distance_to(figure) }.each_with_index.min[1]
      closest_skull = skulls[skull_index]
      closest_skull.skeleton_figure = skeleton
      closest_skull.save!
    end
  end

end
