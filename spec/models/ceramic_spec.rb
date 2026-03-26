require 'rails_helper'

RSpec.describe Ceramic, type: :model do
  let(:ceramic) { build(:ceramic) }

  it 'is a subclass of Figure' do
    expect(Ceramic < Figure).to be true
  end

  describe 'with_unit' do
    it 'has with_unit for area' do
      expect(ceramic.respond_to?(:area_with_unit)).to be true
    end

    it 'has with_unit for perimeter' do
      expect(ceramic.respond_to?(:perimeter_with_unit)).to be true
    end

    it 'has with_unit for width' do
      expect(ceramic.respond_to?(:width_with_unit)).to be true
    end

    it 'has with_unit for height' do
      expect(ceramic.respond_to?(:height_with_unit)).to be true
    end
  end

  describe '#figures' do
    it 'returns ceramic and scale' do
      ceramic = create(:ceramic)
      scale = create(:scale, parent: ceramic)

      expect(ceramic.figures).to include(ceramic, scale)
    end
  end
end
