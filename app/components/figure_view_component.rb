# frozen_string_literal: true

class FigureViewComponent < ViewComponent::Base
  def initialize(figures:, image:)
    @figures = figures
    @image = image
  end
end
