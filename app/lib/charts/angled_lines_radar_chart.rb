module Charts
  class AngledLinesRadarChart < RadarChart
    def initialize(angles, **kwargs)
      super(**kwargs)
      @angles = angles
    end

    def render
      super
      @angles.each do |angle|
        @svg.line(x1: @center, x2: @center, y1: 0, y2: @size, class: "angle-line",
          transform: "rotate(#{angle} #{@center} #{@center})", stroke: "#F4511E", stroke_width: 1)
      end
      @svg.render
    end

    def set_css
      @svg.css = {
        ".angle-line": {
          "shape-rendering" => "geometricprecision"
        }
      }
    end
  end
end
