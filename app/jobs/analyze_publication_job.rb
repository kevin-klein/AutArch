class AnalyzePublicationJob < ApplicationJob
  queue_as :default

  def perform(publication, site_id: nil)
    AnalyzePublication.new.run(publication, site_id: nil)
  end
end
