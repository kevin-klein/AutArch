class CreateGraves

  def initialize

  end

  def run
    Page.includes(:figures).find_each do |page|
      figures = convert_figures(page.figures)

      grave_figures = figures['grave']
      grave_figures&.each do |grave|
        handle_grave(grave, figures)
      end
    end
  end

  def convert_figures(figures)
    result = {}

    figures.each do |figure|
      arr = result[figure.type_name]
      arr ||= []
      arr << figure
      result[figure.type_name] = arr
    end

    result
  end

  def handle_grave(grave_figure, figures)
    non_grave_figures = figures.values.flatten.select { |figure| figure.type_name != 'grave' }

    inside_grave = non_grave_figures.select { |figure| grave_figure.collides?(figure) }

    grave = Grave.create!(
      figure: grave_figure,
    )

    find_closest_item(grave_figure, figures['scale']) do |closest_scale|
      Scale.create!(
        grave: grave,
        figure: closest_scale
      )
    end

    find_closest_item(grave_figure, figures['arrow']) do |closest_arrow|
      Arrow.create!(
        grave: grave,
        figure: closest_arrow,
      )
    end

    skeletons = inside_grave.select { |figure| figure.type_name == 'skeleton' }
    skeletons.each { |skeleton| handle_skeleton(skeleton, grave, figures) }

    goods = inside_grave.select { |figure| figure.type_name == 'goods' }
    goods.each do |good|
      Good.create!(
        figure: good,
        grave: grave
      )
    end

    find_closest_item(grave_figure, figures['grave_cross_section']) do |cross|
      GraveCrossSection.create!(
        figure: cross,
        grave: grave
      )
    end
  end

  def find_closest_item(grave_figure, figures)
    return if figures.nil?

    figure_index = figures.map { |figure| grave_figure.distance_to(figure) }.each_with_index.min[1]
    closest_figure = figures[figure_index]
    yield closest_figure
  end

  def handle_skeleton(skeleton_figure, grave, figures)
    skeleton = Skeleton.create!(
      grave: grave,
      figure: skeleton_figure
    )

    skulls = figures['skull']
    if skulls.present?
      skull_index = skulls.map { |figure| grave.figure.distance_to(figure) }.each_with_index.min[1]
      closest_skull = skulls[skull_index]
      Skull.create!(
        skeleton: skeleton,
        figure: closest_skull,
      )
    end
  end

end
