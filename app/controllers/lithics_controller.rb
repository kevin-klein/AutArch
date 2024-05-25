class LithicsController < ApplicationController
  pyimport "scipy"
  pyimport "numpy"
  pyimport "io"
  pyimport "base64"
  pyfrom "matplotlib", import: :pyplot

  def index
    @lithics = StoneTool
      .includes(:scale)
      .joins(:scale)
      .where("figures.probability > ?", 0.5)
      .where(publication: Publication.find(33))
      .where(type: "StoneTool")
      .filter { _1.scale&.meter_ratio.present? }
      .filter { !_1.contour.empty? }
      # .map(&:size_normalized_contour)
      .filter do |lithic|
        contour = lithic.size_normalized_contour
        if contour.empty?
          false
        else
          rect = ImageProcessing.minAreaRect(contour)
          true
          # rect[:height] < 400
          # rect[:width] < 500 && rect[:height] < 500 && !contour.flatten.any? { _1 < 0 }
        end
      end
      .first(120)

    ap @lithics.last.page_id

    @contours = @lithics.map(&:size_normalized_contour)
    @efd_data = @contours.map { Efd.elliptic_fourier_descriptors(_1, normalize: false, order: 15).to_a.flatten }
    @efd_data = @efd_data.map { |item| item.each_slice(2).map(&:last) }
    @efd_pca_chart = Stats.efd_pca(@efd_data)

    @efd_pca_chart = Stats.base_pca_chart(@efd_pca_chart)
    ap Stats.efd_pca(@efd_data)

    # ap @lithics.map(&:scale).map(&:meter_ratio)
    # ap @lithics[10]
    # ap @lithics.map { ap ImageProcessing.minAreaRect(_1.size_normalized_contour) }
    # ap @contours
    # ap @contours.map { ImageProcessing.minAreaRect(_1) }
  end

  def show
    @lithic = StoneTool.find(params[:id])
  end
end
