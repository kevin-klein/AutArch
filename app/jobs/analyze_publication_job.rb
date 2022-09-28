class AnalyzePublicationJob < ApplicationJob
  queue_as :default

  def perform(publication)
    AnalyzePdf.process_pdf(publication)
  end
end
