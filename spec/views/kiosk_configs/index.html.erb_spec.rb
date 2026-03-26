require 'rails_helper'

RSpec.describe "kiosk_configs/index", type: :view do
  before(:each) do
    assign(:kiosk_configs, [
      KioskConfig.create!(
        page: nil,
        figure: nil
      ),
      KioskConfig.create!(
        page: nil,
        figure: nil
      )
    ])
  end

  it "renders a list of kiosk_configs" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
