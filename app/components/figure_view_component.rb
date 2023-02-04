# frozen_string_literal: true

class FigureViewComponent < ViewComponent::Base
  def initialize(figures:, image:)
    super
    @figures = figures
    @image = image
  end
end
