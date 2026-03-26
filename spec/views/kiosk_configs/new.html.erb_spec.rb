require 'rails_helper'

RSpec.describe "kiosk_configs/new", type: :view do
  before(:each) do
    assign(:kiosk_config, KioskConfig.new(
      page: nil,
      figure: nil
    ))
  end

  it "renders new kiosk_config form" do
    render

    assert_select "form[action=?][method=?]", kiosk_configs_path, "post" do

      assert_select "input[name=?]", "kiosk_config[page_id]"

      assert_select "input[name=?]", "kiosk_config[figure_id]"
    end
  end
end
