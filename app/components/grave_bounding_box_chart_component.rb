# frozen_string_literal: true

class GraveBoundingBoxChartComponent < ViewComponent::Base
  def initialize(angles:)
    super
    @angles = angles
  end

  def radar_box_svg
    chart = RadarChart.new
    svg = chart.render

    svg.render
  end
end
