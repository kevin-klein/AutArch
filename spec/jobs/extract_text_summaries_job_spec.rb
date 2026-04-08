require 'rails_helper'

RSpec.describe ExtractTextSummariesJob, type: :job do
  let(:user) { create(:user) }
  let(:publication) { create(:publication_with_pages, pages_count: 1) }

  before do
    # Set default URL options for URL helpers
    Rails.application.routes.default_url_options = { host: 'localhost', port: 3000 }

    # Create figures with identifiers
    @figure_h166 = Figure.create!(
      publication: publication,
      page: publication.pages.first,
      identifier: 'H166',
      type: 'Grave',
      x1: 100, y1: 100, x2: 200, y2: 200,
      width: 100,
      height: 100,
      angle: 0,
      probability: 0.8
    )
    @figure_h121 = Figure.create!(
      publication: publication,
      page: publication.pages.first,
      identifier: 'H121',
      type: 'Ceramic',
      x1: 300, y1: 300, x2: 400, y2: 400,
      width: 100,
      height: 100,
      angle: 0,
      probability: 0.9
    )
  end

  describe '#perform' do
    it 'enqueues the job' do
      expect do
        ExtractTextSummariesJob.perform_later(publication, ['H166', 'H121'])
      end.to have_enqueued_job.on_queue('default')
    end

    it 'calls the Python microservice endpoint' do
      # Mock the HTTParty response
      mock_response = double
      allow(mock_response).to receive(:success?).and_return(true)
      allow(mock_response).to receive(:parsed_response).and_return({
        'summaries' => [
          { 'id' => 'H166', 'summary' => 'Grave with pottery', 'confidence' => 'high' },
          { 'id' => 'H121', 'summary' => 'Ceramic vessel', 'confidence' => 'high' }
        ]
      })

      allow(HTTParty).to receive(:post).and_return(mock_response)

      ExtractTextSummariesJob.perform_now(publication, ['H166', 'H121'])

      # Verify HTTParty was called at all
      expect(HTTParty).to have_received(:post).once
    end

    it 'updates figure records with summaries' do
      # Mock the HTTParty response
      mock_response = double
      allow(mock_response).to receive(:success?).and_return(true)
      allow(mock_response).to receive(:parsed_response).and_return({
        'summaries' => [
          { 'id' => 'H166', 'summary' => 'Grave with pottery', 'confidence' => 'high' },
          { 'id' => 'H121', 'summary' => 'Ceramic vessel', 'confidence' => 'high' }
        ]
      })

      allow(HTTParty).to receive(:post).and_return(mock_response)

      ExtractTextSummariesJob.perform_now(publication, ['H166', 'H121'])

      # Reload figures from database
      figure_h166 = Figure.find(@figure_h166.id)
      figure_h121 = Figure.find(@figure_h121.id)

      expect(figure_h166.text_summary).to eq('Grave with pottery')
      expect(figure_h121.text_summary).to eq('Ceramic vessel')
    end

    it 'handles missing figures gracefully' do
      # Mock the HTTParty response with a summary for a non-existent figure
      mock_response = double
      allow(mock_response).to receive(:success?).and_return(true)
      allow(mock_response).to receive(:parsed_response).and_return({
        'summaries' => [
          { 'id' => 'NONEXISTENT', 'summary' => 'This should not be saved', 'confidence' => 'high' }
        ]
      })

      allow(HTTParty).to receive(:post).and_return(mock_response)

      expect {
        ExtractTextSummariesJob.perform_now(publication, ['NONEXISTENT'])
      }.not_to change(Figure, :count)

      # Verify no figure was updated
      publication.figures.each do |figure|
        figure.reload
        expect(figure.text_summary).to be_nil
      end
    end

    it 'logs errors when API call fails' do
      # Mock failed API response
      mock_response = double
      allow(mock_response).to receive(:success?).and_return(false)
      allow(mock_response).to receive(:code).and_return('500')
      allow(mock_response).to receive(:body).and_return('Internal Server Error')

      allow(HTTParty).to receive(:post).and_return(mock_response)

      expect(Rails.logger).to receive(:error).with(/Failed to extract text summaries/)

      ExtractTextSummariesJob.perform_now(publication, ['H166'])
    end

    it 'logs warnings when figure is not found' do
      # Mock successful API response with missing figure
      mock_response = double
      allow(mock_response).to receive(:success?).and_return(true)
      allow(mock_response).to receive(:parsed_response).and_return({
        'summaries' => [
          { 'id' => 'NONEXISTENT', 'summary' => 'Summary', 'confidence' => 'high' }
        ]
      })

      allow(HTTParty).to receive(:post).and_return(mock_response)

      expect(Rails.logger).to receive(:warn).with(/Figure with identifier NONEXISTENT not found/)

      ExtractTextSummariesJob.perform_now(publication, ['NONEXISTENT'])
    end
  end
end
