size = 600
radius = (size / 2) * 0.9
grey_stroke = "#BDBDBD"
center = size / 2

# hue 0..360
# saturation 0..1
# value 0..1
# https://en.wikipedia.org/wiki/HSL_and_HSV#HSV_to_RGB_alternative
def helper_function(n, hue, saturation, value) # rubocop:disable Naming/MethodParameterName
  k = (n + (hue / 60)) % 6
  value - (value * saturation * [0, [k, 4 - k, 1].min].max)
end

def hsv_to_rgb(hue, saturation, value)
  red = helper_function(5, hue, saturation, value) * 255
  green = helper_function(3, hue, saturation, value) * 255
  blue = helper_function(1, hue, saturation, value) * 255

  [red, green, blue].map(&:to_i)
end

svg = Victor::SVG.new template: :html, width: 1000, height: 1000
svg.css = {
  ".point:hover": {
    # opacity: 0.6
    filter: "brightness(0.7)"
  }
}

(0.4..1.0).step(0.2).each do |factor|
  svg.circle cx: center, cy: center, r: radius * factor, stroke: grey_stroke, stroke_width: 1, fill: "none"
end
# distance from smallest to largest circle
circle_distance = (radius - (radius * 0.4))

text_center_x = center
text_center_y = center - radius - 10
(0..340).step(30).each do |angle|
  svg.text "#{angle}°", transform: "rotate(#{angle} #{center} #{center})", x: text_center_x, y: text_center_y
end

(0..360).step(30).each do |angle|
  svg.line(x1: center, x2: center, y1: 0, y2: 2 * radius,
    transform: "rotate(#{angle} #{center} #{center})", stroke: grey_stroke, stroke_width: 1)
end

max_count = data.map { |_key, value| value }.max

max_size = size / 20
data.each do |angle, count|
  percent_size = (count.to_f / max_count)
  stroke = hsv_to_rgb(angle, Random.rand(50..100) / 100.0, Random.rand(80..100) / 100.0)
  stroke = "rgb(#{stroke[0]} #{stroke[1]} #{stroke[2]})"
  svg.circle class: "point", r: max_size * percent_size, cx: center, cy: ((1 - percent_size) * circle_distance) + (max_size * 2),
    stroke: grey_stroke, stroke_width: 1, fill: stroke, transform: "rotate(#{angle} #{center} #{center})" do
    svg.title count
  end
  # svg.text count, x: center, y: ((1 - percent_size) * circle_distance) + (max_size * 2),
  #                 transform: "rotate(#{angle} #{center} #{center})"
end
svg.render
