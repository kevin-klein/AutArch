module CosineSimilarity
  module_function

  def similarity(first, second)
    dot_product = 0
    first.zip(second).each do |v1i, v2i|
      dot_product += v1i * v2i
    end
    a = first.map { |n| n**2 }.reduce(:+)
    b = second.map { |n| n**2 }.reduce(:+)
    dot_product / (Math.sqrt(a) * Math.sqrt(b))
  end
end
