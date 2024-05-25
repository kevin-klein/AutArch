module LithicStats
  module_function

  def efd(lithics)
    contours = lithics.map(&:size_normalized_contour)
    contours.map { Efd.elliptic_fourier_descriptors(_1, normalize: false, order: 15).to_a.flatten }
    frequencies = frequencies.map { |item| item.each_slice(2).map(&:last) }
  end
end
