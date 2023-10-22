module Distance
  extend self

  def point_distance(point1, point2)
    item1 = (point1[:x] - point2[:x])**2
    item2 = (point1[:y] - point2[:y])**2

    Math.sqrt(item1 + item2)
  end
end
