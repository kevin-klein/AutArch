require "application_system_test_case"

class ChronologiesTest < ApplicationSystemTestCase
  setup do
    @chronology = chronologies(:one)
  end

  test "visiting the index" do
    visit chronologies_url
    assert_selector "h1", text: "Chronologies"
  end

  test "should create chronology" do
    visit chronologies_url
    click_on "New chronology"

    fill_in "Context from", with: @chronology.context_from
    fill_in "Context to", with: @chronology.context_to
    fill_in "Period", with: @chronology.period
    click_on "Create Chronology"

    assert_text "Chronology was successfully created"
    click_on "Back"
  end

  test "should update Chronology" do
    visit chronology_url(@chronology)
    click_on "Edit this chronology", match: :first

    fill_in "Context from", with: @chronology.context_from
    fill_in "Context to", with: @chronology.context_to
    fill_in "Period", with: @chronology.period
    click_on "Update Chronology"

    assert_text "Chronology was successfully updated"
    click_on "Back"
  end

  test "should destroy Chronology" do
    visit chronology_url(@chronology)
    click_on "Destroy this chronology", match: :first

    assert_text "Chronology was successfully destroyed"
  end
end
