# frozen_string_literal: true

class LithicOutlinesComponent < ViewComponent::Base
  def initialize(lithics:, color: [209, 41, 41])
    super
    @lithics = lithics
    @color = "rgb(#{color.join(' ')})"
  end
end
