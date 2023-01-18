require "application_system_test_case"

class BonesTest < ApplicationSystemTestCase
  setup do
    @bone = bones(:one)
  end

  test "visiting the index" do
    visit bones_url
    assert_selector "h1", text: "Bones"
  end

  test "should create bone" do
    visit bones_url
    click_on "New bone"

    fill_in "Name", with: @bone.name
    click_on "Create Bone"

    assert_text "Bone was successfully created"
    click_on "Back"
  end

  test "should update Bone" do
    visit bone_url(@bone)
    click_on "Edit this bone", match: :first

    fill_in "Name", with: @bone.name
    click_on "Update Bone"

    assert_text "Bone was successfully updated"
    click_on "Back"
  end

  test "should destroy Bone" do
    visit bone_url(@bone)
    click_on "Destroy this bone", match: :first

    assert_text "Bone was successfully destroyed"
  end
end
