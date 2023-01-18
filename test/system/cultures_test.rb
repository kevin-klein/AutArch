require "application_system_test_case"

class CulturesTest < ApplicationSystemTestCase
  setup do
    @culture = cultures(:one)
  end

  test "visiting the index" do
    visit cultures_url
    assert_selector "h1", text: "Cultures"
  end

  test "should create culture" do
    visit cultures_url
    click_on "New culture"

    fill_in "Name", with: @culture.name
    click_on "Create Culture"

    assert_text "Culture was successfully created"
    click_on "Back"
  end

  test "should update Culture" do
    visit culture_url(@culture)
    click_on "Edit this culture", match: :first

    fill_in "Name", with: @culture.name
    click_on "Update Culture"

    assert_text "Culture was successfully updated"
    click_on "Back"
  end

  test "should destroy Culture" do
    visit culture_url(@culture)
    click_on "Destroy this culture", match: :first

    assert_text "Culture was successfully destroyed"
  end
end
