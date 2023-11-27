# frozen_string_literal: true

class GraveOutlinesComponent < ViewComponent::Base
  def initialize(graves:, title:, subtitle:, color:)
    super
    @color = color
    @graves = Stats.filter_graves(graves)
    @title = title
    @subtitle = subtitle
  end
end
