require 'rails_helper'

RSpec.describe "kiosk_configs/show", type: :view do
  before(:each) do
    assign(:kiosk_config, KioskConfig.create!(
      page: nil,
      figure: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
