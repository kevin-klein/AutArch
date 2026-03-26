require 'rails_helper'

RSpec.describe ObjectSimilarity, type: :model do
  describe 'associations' do
    it { should belong_to(:first).class_name('Figure') }
    it { should belong_to(:second).class_name('Figure') }
  end

  describe 'validations' do
    it { should validate_presence_of(:first) }
    it { should validate_presence_of(:second) }
  end

  it 'stores similarity score between two figures' do
    first_figure = create(:figure)
    second_figure = create(:figure)

    similarity = ObjectSimilarity.create!(
      first: first_figure,
      second: second_figure,
      similarity: 0.85
    )

    expect(similarity.first).to eq(first_figure)
    expect(similarity.second).to eq(second_figure)
    expect(similarity.similarity).to be_within(0.001).of(0.85)
  end
end
