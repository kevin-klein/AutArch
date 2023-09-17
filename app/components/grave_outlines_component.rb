# frozen_string_literal: true

class GraveOutlinesComponent < ViewComponent::Base
  def initialize(graves:)
    @graves = graves
  end

end
