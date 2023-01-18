require "application_system_test_case"

class PeriodsTest < ApplicationSystemTestCase
  setup do
    @period = periods(:one)
  end

  test "visiting the index" do
    visit periods_url
    assert_selector "h1", text: "Periods"
  end

  test "should create period" do
    visit periods_url
    click_on "New period"

    fill_in "Name", with: @period.name
    click_on "Create Period"

    assert_text "Period was successfully created"
    click_on "Back"
  end

  test "should update Period" do
    visit period_url(@period)
    click_on "Edit this period", match: :first

    fill_in "Name", with: @period.name
    click_on "Update Period"

    assert_text "Period was successfully updated"
    click_on "Back"
  end

  test "should destroy Period" do
    visit period_url(@period)
    click_on "Destroy this period", match: :first

    assert_text "Period was successfully destroyed"
  end
end
