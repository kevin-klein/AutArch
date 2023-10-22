# frozen_string_literal: true

class GraveOutlinesComponent < ViewComponent::Base
  def initialize(graves:, title:)
    super
    @graves = Stats.filter_graves(graves)
    @title = title
  end
end
