module Contour
  extend self

  def to_numo(image)
    Numo::NArray[image.get_pixels]
  end

  def find_contours(image)
    arr = to_numo(image)
    arr.each_with_index do |a, *i|
      ap "i: #{i}"
    end
  end
end
