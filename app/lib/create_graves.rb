class CreateGraves

  def build
    Page.transaction do
      Page.includes(:figures).find_each do |page|
        figures = convert_figures(page.figures)

        grave_figures = figures['grave']
        grave_figures&.each do |grave|
          handle_grave(grave, figures)
        end
      end
    end
  end

  def convert_figures(figures)
    result = {}

    figures.each do |figure|
      if ['arrow_up', 'arrow_left', 'arrow_right'].include?(figure.type_name)
        arr = result['arrow']
        arr ||= []
        arr << figure
        result['arrow'] = arr
      else
        arr = result[figure.type_name]
        arr ||= []
        arr << figure
        result[figure.type_name] = arr
      end
    end

    result
  end

  def handle_grave(grave_figure, figures)
    non_grave_figures = figures.values.flatten.select { |figure| figure.type_name != 'grave' }

    inside_grave = non_grave_figures.select { |figure| grave_figure.collides?(figure) }

    grave = Grave.create!(
      figure: grave_figure,
    )

    find_closest_item(figures['scale']) do |closest_scale|
      Scale.create!(
        grave: grave,
        figure: closest_scale
      )
    end

    find_closest_item(figures['arrow']) do |closes_arrow|
      Arrow.create!(
        grave: grave,
        figure: closest_arrow,
      )
    end

    corpses = inside_grave.select { |figure| ['skeleton_left_side', 'skeleton_right_side'].include?(figure.type_name) }
    corpses.each { |corpse| handle_corpse(corpse, grave, figures) }

    goods = inside_grave.select { |figure| figure.type_name == 'goods' }
    goods.each do |good|
      Good.create!(
        figure: good,
        grave: grave
      )
    end

    find_closest_item('grave_cross_section') do |cross|

    end
  end

  def find_closest_item(figures)
    return if figures.nil?

    figure_index = figures.map { |figure| grave_figure.distance_to(figure) }.each_with_index.min[1]
    closest_figure = figures[figure_index]
    yield closest_figure
  end

  def handle_corpse(corpse_figure, grave, figures)
    corpse = Corpse.create!(
      grave: grave,
      figure: corpse_figure
    )

    skulls = figures['skull']
    if skulls.present?
      skull_index = skulls.map { |figure| grave.figure.distance_to(figure) }.each_with_index.min[1]
      closest_skull = skulls[skull_index]
      Skull.create!(
        corpse: corpse,
        figure: closest_skull,
      )
    end
  end

end
