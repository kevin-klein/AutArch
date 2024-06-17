module Charts
  class ScatterChart < Chart
    def initialize(data, x_legend: "", y_legend: "", padding: 100, height: 400, width: 1200, link_proc: proc {}, **kwargs) # rubocop:disable Metrics/ParameterLists
      super(width: width, height: height, padding: padding, **kwargs)
      @data = data
      @axis_marker_height = 5
      @link_proc = link_proc
      @x_legend = x_legend
      @y_legend = y_legend
      calculate_stats
    end

    def render
      draw_x_y_axis

      render_data
      @svg.render
    end

    private

    def render_standard_series(series, color: "red")
      series[:data].each do |item|
        render_item(item, color) unless item[:mark]
      end
    end

    def render_marked_series(series, color: "red")
      series[:data].each do |item|
        render_marked_item(item, color) if item[:mark]
      end
    end

    def render_item(item, color, stroke: "black")
      @svg.circle onclick: "window.location='#{@link_proc.call(item)}'", class: "point", r: 4, fill: color,
        cx: x_coordinate(item[:x]), cy: y_coordinate(item[:y]), stroke: stroke do
        @svg.title item[:title]
      end
    end

    def render_marked_item(item, color)
      render_item(item, color, stroke: "black")
      @svg.text item[:title], x: x_coordinate(item[:x]) + 5, y: y_coordinate(item[:y])
    end

    def render_data
      angle = 360.0 / @data.count
      @data.each.with_index do |series, index|
        color = Helpers.color_by_angle(angle * index)
        render_standard_series(series, color: color)
        render_legend(series, index, color: color)
      end

      @data.each.with_index do |series, index|
        color = Helpers.color_by_angle(angle * index)
        render_marked_series(series, color: color)
      end
    end

    def render_legend(series, index, color:)
      @svg.text "#{series[:name]} (N=#{series[:data].length})", x: @width / 2, y: @padding + (index * 15)
      @svg.rect fill: color, width: 10, height: 10, x: (@width / 2) - 15, y: @padding + (index * 15) - 10
    end

    def draw_x_y_axis
      @svg.line(x1: @padding, y1: 0, x2: @padding, y2: @height, stroke: @grey_stroke, stroke_width: 1)
      @svg.line(y1: @height - @padding, x1: 0, y2: @height - @padding, x2: @width, stroke: @grey_stroke,
        stroke_width: 1)
      draw_x_axis_text
      draw_y_axis_text
      draw_axis_legend
    end

    def draw_axis_legend
      @svg.text(@x_legend, x: @width / 2, y: @height)
      @svg.text(@y_legend, x: 10, y: @height / 2, transform: "rotate(-90 5 #{(@height / 2) - 5})")
    end

    def draw_x_axis_text
      step = ((@max_x - @min_x) / 10).to_i
      if step == 0
        step = 1
      end
      ((@min_x.to_i + 1)..(@max_x.to_i)).step(step).each do |x_value|
        @svg.line(x1: x_coordinate(x_value), y1: (@height - @padding) - @axis_marker_height, x2: x_coordinate(x_value),
          y2: (@height - @padding) + @axis_marker_height, stroke: @grey_stroke,
          stroke_width: 1)
        @svg.text x_value.round(1), x: x_coordinate(x_value) - 10, y: @height - @padding + 20
      end
    end

    def draw_y_axis_text
      step = ((@max_y - @min_y) / 10).to_i
      if step == 0
        step = 1
      end
      ((@min_y.to_i + 1)..(@max_y.to_i)).step(step).each do |y_value|
        @svg.line(y1: y_coordinate(y_value), x1: @padding - @axis_marker_height, y2: y_coordinate(y_value),
          x2: @padding + @axis_marker_height,
          stroke: @grey_stroke,
          stroke_width: 1)
        @svg.text y_value.round(1), y: y_coordinate(y_value) + 5, x: @padding - 20
      end
    end

    def x_coordinate(value)
      (value + @x_value_padding) * @x_factor
    end

    def y_coordinate(value)
      (@height - @padding) - ((value + @y_value_padding) * @y_factor)
    end

    def calculate_stats # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      data = @data.map { _1[:data] }.flatten
      @max_x = data.map { _1[:x] }.max
      @max_x = if @max_x > 0
        @max_x * 1.3
      else
        @max_x * -1.5
      end
      @max_y = data.map { _1[:y] }.max * 1.3
      @min_x = data.map { _1[:x] }.min
      @min_x = if @min_x < 0
        @min_x * -0.6
      else
        @min_x * 0.6
      end
      @min_y = data.map { _1[:y] }.min
      @min_x += (@min_x * 0.1) if @min_x.negative?
      @min_x -= (@min_x * 0.1) if @min_x.positive?
      @min_y += (@min_y * 0.1) if @min_y.negative?
      @min_y -= (@min_y * 0.1) if @min_y.positive?
      @x_value_padding = 0
      @y_value_padding = 0
      @x_value_padding = -@min_x if @min_x.negative?
      @y_value_padding = -@min_y if @min_y.negative?
      @x_factor = (@width - @padding) / (@max_x - @min_x)
      @y_factor = (@height - @padding) / (@max_y - @min_y)

      @x_factor = [@x_factor, @y_factor].min
      @y_factor = @x_factor
      @x_value_padding += 4
    end
  end
end
