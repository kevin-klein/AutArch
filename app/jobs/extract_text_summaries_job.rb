require 'httparty'

class ExtractTextSummariesJob < ApplicationJob
  include Rails.application.routes.url_helpers

  queue_as :default

  def perform(publication, identifiers)
    # Build the request to the Python microservice
    pdf_url = rails_blob_url(publication.pdf)

    response = HTTParty.post(
      'http://localhost:9000/extract_summaries',
      body: {
        pdf_url: pdf_url,
        identifiers: identifiers
      }.to_json,
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 3000
    )

    if response.success?
      summaries = response.parsed_response['summaries']

      # Process each summary and update figures
      summaries.each do |summary_data|
        figure = publication.figures.find_by(identifier: summary_data['id'])
        if figure
          figure.update(
            text_summary: summary_data['summary']
          )
          Rails.logger.info("Extracted text summary for figure #{figure.id} (#{figure.identifier}): #{summary_data['summary']}")
        else
          Rails.logger.warn("Figure with identifier #{summary_data['id']} not found in publication #{publication.id}")
        end
      end

      true
    else
      Rails.logger.error("Failed to extract text summaries: #{response.code} - #{response.body}")
      false
    end
  end
end
