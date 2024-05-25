# frozen_string_literal: true

class LithicOutlinesComponent < ViewComponent::Base
  def initialize(contours:, color: [209, 41, 41])
    super
    @contours = contours

    @color = "rgb(#{color.join(" ")})"
  end
end
