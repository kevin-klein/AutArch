module FiguresHelper
  def number_with_unit(n)
    return "" if n.nil? || n[:value].nil?

    if n[:value] < 0.1 && n[:unit] == "m"
      "#{"%.2f" % (n[:value] * 100)} cm"
    else
      "#{"%.2f" % n[:value]} #{n[:unit]}"
    end
  end
end
