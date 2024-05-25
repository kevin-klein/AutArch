module Charts
  class Chart
    def initialize(
      width: 600,
      height: 600,
      padding: 5,
      html_class: ""
    )
      @grey_stroke = "#BDBDBD"
      @padding = padding
      @width = width
      @height = height
      @svg = Victor::SVG.new template: :html, width: width, height: height, class: html_class
      set_css
    end

    def set_css
      @svg.css = {
        ".point:hover": {
          filter: "brightness(0.7)"
        }
      }
    end
  end
end
