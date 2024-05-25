# frozen_string_literal: true

class GraveOutlinesComponent < ViewComponent::Base
  def initialize(graves:, title:, subtitle:, color:)
    super
    @graves = Stats.filter_graves(graves)
    @title = title
    @color = "rgb(#{color.join(" ")})"
    @subtitle = subtitle
  end
end
