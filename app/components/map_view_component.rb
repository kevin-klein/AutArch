# frozen_string_literal: true

class MapViewComponent < ViewComponent::Base
  def initialize(text_items:, image:)
    super
    @text_items = text_items
    @image = image
  end
end
