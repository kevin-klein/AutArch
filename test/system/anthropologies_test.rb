require "application_system_test_case"

class AnthropologiesTest < ApplicationSystemTestCase
  setup do
    @anthropology = anthropologies(:one)
  end

  test "visiting the index" do
    visit anthropologies_url
    assert_selector "h1", text: "Anthropologies"
  end

  test "should create anthropology" do
    visit anthropologies_url
    click_on "New anthropology"

    fill_in "Age as reported", with: @anthropology.age_as_reported
    fill_in "Age class", with: @anthropology.age_class
    fill_in "Height", with: @anthropology.height
    fill_in "Pathologies", with: @anthropology.pathologies
    fill_in "Pathologies type", with: @anthropology.pathologies_type
    fill_in "Sex consensus", with: @anthropology.sex_consensus
    fill_in "Sex gen", with: @anthropology.sex_gen
    fill_in "Sex morph", with: @anthropology.sex_morph
    click_on "Create Anthropology"

    assert_text "Anthropology was successfully created"
    click_on "Back"
  end

  test "should update Anthropology" do
    visit anthropology_url(@anthropology)
    click_on "Edit this anthropology", match: :first

    fill_in "Age as reported", with: @anthropology.age_as_reported
    fill_in "Age class", with: @anthropology.age_class
    fill_in "Height", with: @anthropology.height
    fill_in "Pathologies", with: @anthropology.pathologies
    fill_in "Pathologies type", with: @anthropology.pathologies_type
    fill_in "Sex consensus", with: @anthropology.sex_consensus
    fill_in "Sex gen", with: @anthropology.sex_gen
    fill_in "Sex morph", with: @anthropology.sex_morph
    click_on "Update Anthropology"

    assert_text "Anthropology was successfully updated"
    click_on "Back"
  end

  test "should destroy Anthropology" do
    visit anthropology_url(@anthropology)
    click_on "Destroy this anthropology", match: :first

    assert_text "Anthropology was successfully destroyed"
  end
end
