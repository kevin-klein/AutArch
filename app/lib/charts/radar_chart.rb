module Charts
  class RadarChart < Chart
    def initialize(
      size: 600,
      **kwargs
    )
      super(**kwargs)
      @size = size
      @radius = (size / 2) * 0.9
      @center = size / 2
    end

    attr_reader :center, :radius, :size

    def render
      draw_circles
      draw_helpers

      @svg
    end

    def draw_helpers
      (0..360).step(30).each do |angle|
        @svg.line(x1: @center, x2: @center, y1: 0, y2: 2 * @radius,
          transform: "rotate(#{angle} #{@center} #{@center})", stroke: @grey_stroke, stroke_width: 1)
      end
      draw_helpers_text
    end

    def draw_circles
      (0.4..1.0).step(0.2).each do |factor|
        @svg.circle cx: @center, cy: @center, r: @radius * factor, stroke: @grey_stroke, stroke_width: 1, fill: "none"
      end
    end

    def draw_helpers_text
      text_center_y = @center - @radius - 10
      (0..340).step(30).each do |angle|
        @svg.text "#{angle}°", transform: "rotate(#{angle} #{@center} #{@center})", x: @center, y: text_center_y
      end
    end
  end
end
