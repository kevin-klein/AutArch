require 'rails_helper'

RSpec.describe PublicationsController, type: :request do
  let(:user) { create(:user) }
  let(:publication) { create(:publication_with_pages) }

  before do
    # Simulate user login by setting session
    session[:user_id] = user.id
    user.update(disabled: false)
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get publications_path
      expect(response).to have_http_status(:ok)
    end

    it 'renders the index template' do
      get publications_path
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'returns a successful response' do
      get publication_path(publication)
      expect(response).to have_http_status(:ok)
    end

    it 'renders the show template' do
      get publication_path(publication)
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #summary' do
    before do
      create(:figure, publication: publication, type: 'Grave', probability: 0.8)
      create(:figure, publication: publication, type: 'Ceramic', probability: 0.9)
      create(:figure, publication: publication, type: 'Arrow', probability: 0.7)
    end

    it 'returns a successful response' do
      get summary_publication_path(publication)
      expect(response).to have_http_status(:ok)
    end

    it 'returns correct figure counts by type' do
      get summary_publication_path(publication)
      data = JSON.parse(response.body)

      expect(data['Burial Mound']).to eq(1)
      expect(data['Ceramic']).to eq(1)
      expect(data['Orientation Arrow']).to eq(1)
    end
  end

  describe 'POST #create_bovw_data' do
    let(:ceramics) do
      create_list(:ceramic, 3, publication: publication)
    end

    it 'creates BOVW training data' do
      ceramics

      expect {
        post create_bovw_data_publication_path(publication)
      }.to change(ObjectSimilarity, :count).by(6) # 3*2 = 6 pairwise similarities
    end

    it 'redirects to publications path' do
      post create_bovw_data_publication_path(publication)
      expect(response).to redirect_to(publications_path)
    end
  end

  describe 'GET #similarities' do
    let(:ceramics) do
      create_list(:ceramic, 3, publication: publication)
    end

    it 'returns a successful response' do
      ceramics

      get similarities_publication_path(publication)
      expect(response).to have_http_status(:ok)
    end

    it 'renders the similarities template' do
      ceramics

      get similarities_publication_path(publication)
      expect(response).to render_template(:similarities)
    end

    it 'assigns ceramics with probability > 0.6' do
      ceramics
      create(:ceramic, publication: publication, probability: 0.5)

      get similarities_publication_path(publication)
      assigns(:ceramics).each do |ceramic|
        expect(ceramic.probability).to be > 0.6
      end
    end

    it 'assigns similarity data' do
      ceramics
      first = ceramics.first
      second = ceramics.second
      ObjectSimilarity.create!(first: first, second: second, similarity: 0.85)

      get similarities_publication_path(publication)
      similarities = assigns(:similarities)
      expect(similarities.length).to eq(3)
    end
  end

  describe 'POST #create' do
    let(:pdf_file) { fixture_file_upload('files/test.pdf', 'application/pdf') }

    it 'creates a new publication' do
      expect {
        post publications_path, params: {
          publication: {
            title: 'Test Publication',
            author: 'Test Author',
            year: '2023',
            pdf: pdf_file
          }
        }
      }.to change(Publication, :count).by(1)
    end

    it 'initiates analysis job' do
      allow(AnalyzePublicationJob).to receive(:perform_later)

      post publications_path, params: {
        publication: {
          title: 'Test Publication',
          author: 'Test Author',
          year: '2023',
          pdf: pdf_file
        }
      }

      expect(AnalyzePublicationJob).to have_received(:perform_later).once
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the publication' do
      expect {
        delete publication_path(publication)
      }.to change(Publication, :count).by(-1)
    end

    it 'redirects to publications path' do
      delete publication_path(publication)
      expect(response).to redirect_to(publications_path)
    end
  end
end
