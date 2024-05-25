# frozen_slithicring_literal: true

class LithicContoursComponent < ViewComponent::Base
  def initialize(lithic:, color: [255, 100, 100])
    super
    @lithic = lithic
    @color = "rgb(#{color.join(" ")})"
    @image_data = ImageProcessing.imencode(
      ImageProcessing.extractFigure(lithic, lithic.page.image.data.download)
    )
    @image = Vips::Image.new_from_buffer(@image_data, "")
    @image_data = "data:image/jpeg;base64,#{Base64.encode64 @image_data}"
    # ap @image_data
    # raise
  end
end
