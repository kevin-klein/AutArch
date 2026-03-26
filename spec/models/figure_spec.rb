require 'rails_helper'

RSpec.describe Figure, type: :model do
  it 'has a valid factory' do
    expect(build(:figure)).to be_valid
  end

  it 'has a valid ceramic factory' do
    expect(build(:ceramic)).to be_valid
  end

  it 'has a valid grave factory' do
    expect(build(:grave)).to be_valid
  end

  it 'has a valid spine factory' do
    expect(build(:spine)).to be_valid
  end

  it 'has a valid arrow factory' do
    expect(build(:arrow)).to be_valid
  end
end
