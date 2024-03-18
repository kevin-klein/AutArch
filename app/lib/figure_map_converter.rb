module FigureMapConverter
  extend self

  def convert_figures(figures)
    result = {}

    figures.each do |figure|
      arr = result[figure.type]
      arr ||= []
      arr << figure
      result[figure.type] = arr
    end

    result
  end
end
