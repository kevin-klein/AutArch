module Charts
  class ClusterRadarChart < RadarChart
    def initialize(clusters, **kwargs)
      super(**kwargs)
      @clusters = clusters

      create_stats
    end

    def render # rubocop:disable Metrics/MethodLength
      super

      @clusters.each do |angle, count|
        percent_size = (count.to_f / @max_count)
        # stroke = stroke_color(angle)
        @svg.circle class: "point",
          r: @max_size * percent_size,
          cx: @center,
          cy: ((1 - percent_size) * @circle_distance) + (@max_size * 2),
          stroke: @grey_stroke,
          stroke_width: 1,
          # fill: stroke,
          fill: "black",
          transform: "rotate(#{angle} #{@center} #{@center})" do
          @svg.title count
        end
      end
      @svg.render
    end

    private

    def stroke_color(angle)
      stroke = Helpers.hsv_to_rgb(angle, Random.rand(50..100) / 100.0, Random.rand(80..100) / 100.0)
      "rgb(#{stroke[0]} #{stroke[1]} #{stroke[2]})"
    end

    def create_stats
      @max_count = @clusters.map { |_key, value| value }.max
      @circle_distance = (@radius - (@radius * 0.4))
      @max_size = size / 20
    end
  end
end
