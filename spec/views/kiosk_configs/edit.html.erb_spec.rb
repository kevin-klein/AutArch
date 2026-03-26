require 'rails_helper'

RSpec.describe "kiosk_configs/edit", type: :view do
  let(:kiosk_config) {
    KioskConfig.create!(
      page: nil,
      figure: nil
    )
  }

  before(:each) do
    assign(:kiosk_config, kiosk_config)
  end

  it "renders the edit kiosk_config form" do
    render

    assert_select "form[action=?][method=?]", kiosk_config_path(kiosk_config), "post" do

      assert_select "input[name=?]", "kiosk_config[page_id]"

      assert_select "input[name=?]", "kiosk_config[figure_id]"
    end
  end
end
