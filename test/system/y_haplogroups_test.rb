require "application_system_test_case"

class YHaplogroupsTest < ApplicationSystemTestCase
  setup do
    @y_haplogroup = y_haplogroups(:one)
  end

  test "visiting the index" do
    visit y_haplogroups_url
    assert_selector "h1", text: "Y haplogroups"
  end

  test "should create y haplogroup" do
    visit y_haplogroups_url
    click_on "New y haplogroup"

    fill_in "Name", with: @y_haplogroup.name
    click_on "Create Y haplogroup"

    assert_text "Y haplogroup was successfully created"
    click_on "Back"
  end

  test "should update Y haplogroup" do
    visit y_haplogroup_url(@y_haplogroup)
    click_on "Edit this y haplogroup", match: :first

    fill_in "Name", with: @y_haplogroup.name
    click_on "Update Y haplogroup"

    assert_text "Y haplogroup was successfully updated"
    click_on "Back"
  end

  test "should destroy Y haplogroup" do
    visit y_haplogroup_url(@y_haplogroup)
    click_on "Destroy this y haplogroup", match: :first

    assert_text "Y haplogroup was successfully destroyed"
  end
end
