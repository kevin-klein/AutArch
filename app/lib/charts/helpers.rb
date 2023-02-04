module Charts
  module Helpers
    module_function

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

    def color_by_angle(angle)
      stroke = Helpers.hsv_to_rgb(angle, Random.rand(50..100) / 100.0, Random.rand(80..100) / 100.0)
      "rgb(#{stroke[0]} #{stroke[1]} #{stroke[2]})"
    end
  end
end
