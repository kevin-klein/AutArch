module Charts
  class BoxPlot < Chart
    def initialize(data, padding: 20, height: 400, width: 1200, link_proc: nil, **kwargs) # rubocop:disable Metrics/ParameterLists
      super(width: width, height: height, padding: padding, **kwargs)
      @data = data
      @axis_marker_height = 5
      calculate_stats
    end

    def render
      draw_x_y_axis

      render_data
      @svg.render
    end

    def render_data
      (@min_x..@max_x).step(30).drop(1).to_a.zip(@data).each do |x, data|
        _, data = data
        data_stats = stats(data)
        draw_stats(x, data_stats)
      end
    end

    def draw_stats(x, data_stats)
      ap data_stats
      @svg.rect(x: x - 10, y: y_coordinate(data_stats[:lower_percentile_value]), width: 20, height: y_coordinate(data_stats[:upper_percentile_value]))
    end

    def percentile_by_value(array, min, max, percentile)
      range = max - min
      (range * percentile) + min
    end

    def stats(data)
      min = data.min
      max = data.max
      median = data.sum(0.0) / data.size
      {
        min: min,
        max: max,
        median: median,
        lower_percentile_value: data.percentile(0.25),
        upper_percentile_value: data.percentile(0.75)
      }
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
    end

    def draw_x_axis_text
      (@min_x..@max_x).step(30).to_a.zip([""] + @data.keys).each do |x_value, text|
        @svg.line(x1: x_coordinate(x_value), y1: (@height - @padding) - @axis_marker_height, x2: x_coordinate(x_value),
          y2: (@height - @padding) + @axis_marker_height, stroke: @grey_stroke,
          stroke_width: 1)
        @svg.text text, x: x_coordinate(x_value) - 10, y: @height
      end
    end

    def draw_y_axis_text
      (@min_y..@max_y).step((@max_y - @min_y) / 10).each do |y_value|
        @svg.line(y1: y_coordinate(y_value), x1: @padding - @axis_marker_height, y2: y_coordinate(y_value),
          x2: @padding + @axis_marker_height,
          stroke: @grey_stroke,
          stroke_width: 1)
        @svg.text y_value.round(1), y: y_coordinate(y_value) + 5, x: 0
      end
    end

    def x_coordinate(value)
      (value + @x_value_padding) * @x_factor
    end

    def y_coordinate(value)
      (@height - @padding) - ((value + @y_value_padding) * @y_factor)
    end

    def calculate_stats # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      data = @data.map { |key, value| value }.flatten
      @max_x = 5 # @data.keys.count * 30
      @max_y = data.max * 1.1
      @min_x = 0
      @min_y = -1
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
    end
  end
end
