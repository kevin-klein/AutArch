require 'rails_helper'

RSpec.describe Publication, type: :model do
  describe 'associations' do
    it { should have_many(:pages).dependent(:destroy) }
    it { should have_many(:figures).through(:pages) }
    it { should have_many(:ceramics).through(:pages) }
    it { should belong_to(:user).optional }
    it { should have_many(:publication_teams).dependent(:destroy) }
    it { should have_many(:teams).through(:publication_teams) }
    it { should have_one_attached(:pdf) }
  end

  describe '#short_description' do
    it 'returns author and year combined' do
      publication = create(:publication, author: 'John Doe', year: '2023')
      expect(publication.short_description).to eq('John Doe 2023')
    end
  end

  describe '#graves' do
    it 'returns only Grave type figures' do
      publication = create(:publication)
      grave1 = create(:grave, publication: publication)
      grave2 = create(:grave, publication: publication)
      ceramic = create(:ceramic, publication: publication)

      graves = publication.graves

      expect(graves.length).to eq(2)
      expect(graves).to include(grave1, grave2)
      expect(graves).not_to include(ceramic)
    end
  end
end
