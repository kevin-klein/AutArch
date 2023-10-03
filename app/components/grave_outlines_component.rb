# frozen_string_literal: true

class GraveOutlinesComponent < ViewComponent::Base
  def initialize(graves:, title:)
    @graves = graves
    @title = title
  end

end
