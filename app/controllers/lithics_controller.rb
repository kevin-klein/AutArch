class LithicsController < ApplicationController
  # pyimport "scipy"
  # pyimport "numpy"
  # pyimport "io"
  # pyimport "base64"
  # pyfrom "matplotlib", import: :pyplot

  def index
    @lithics = StoneTool
      .includes(:scale)
      .joins(:scale)
      # .where("figures.probability > ?", 0.5)
      .where(publication: Publication.find(32))
      .where(type: "StoneTool")
      .filter { _1.scale&.meter_ratio.present? }
      .filter { !_1.contour.empty? }
      # .map(&:size_normalized_contour)
      .filter do |lithic|
        # ap lithic
        contour = lithic.size_normalized_contour
        if contour.empty?
          false
        else
          # rect = MinOpenCV.minAreaRect(contour)
          true
          # rect[:height] < 400
          # rect[:width] < 500 && rect[:height] < 500 && !contour.flatten.any? { _1 < 0 }
        end
      end
      .sample(100)

    # raise

    @contours = @lithics.map { _1.size_normalized_contour(x_width: 0.1, y_width: 0.1) }
    @efd_data = @contours.map { Efd.elliptic_fourier_descriptors(_1, normalize: false, order: 15).to_a.flatten }
    @efd_data = @efd_data.map { |item| item.each_slice(2).map(&:last) }
    @efd_pca_chart = Stats.efd_pca(@efd_data)

    # @efd_pca_chart = Stats.base_pca_chart(@efd_pca_chart)

    # ap @lithics.map(&:scale).map(&:meter_ratio)
    # ap @lithics[10]
    # ap @lithics.map { ap MinOpenCV.minAreaRect(_1.size_normalized_contour) }
    # ap @contours
    # ap @contours.map { MinOpenCV.minAreaRect(_1) }
  end

  def show
    @lithic = StoneTool.find(params[:id])
  end
end
