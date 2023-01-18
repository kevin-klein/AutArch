require "application_system_test_case"

class StableIsotopesTest < ApplicationSystemTestCase
  setup do
    @stable_isotope = stable_isotopes(:one)
  end

  test "visiting the index" do
    visit stable_isotopes_url
    assert_selector "h1", text: "Stable isotopes"
  end

  test "should create stable isotope" do
    visit stable_isotopes_url
    click_on "New stable isotope"

    fill_in "Baseline", with: @stable_isotope.baseline
    fill_in "Iso bone", with: @stable_isotope.iso_bone
    fill_in "Iso", with: @stable_isotope.iso_id
    fill_in "Iso value", with: @stable_isotope.iso_value
    fill_in "Isotope", with: @stable_isotope.isotope
    fill_in "Ref iso", with: @stable_isotope.ref_iso
    fill_in "Skeleton", with: @stable_isotope.skeleton_id
    click_on "Create Stable isotope"

    assert_text "Stable isotope was successfully created"
    click_on "Back"
  end

  test "should update Stable isotope" do
    visit stable_isotope_url(@stable_isotope)
    click_on "Edit this stable isotope", match: :first

    fill_in "Baseline", with: @stable_isotope.baseline
    fill_in "Iso bone", with: @stable_isotope.iso_bone
    fill_in "Iso", with: @stable_isotope.iso_id
    fill_in "Iso value", with: @stable_isotope.iso_value
    fill_in "Isotope", with: @stable_isotope.isotope
    fill_in "Ref iso", with: @stable_isotope.ref_iso
    fill_in "Skeleton", with: @stable_isotope.skeleton_id
    click_on "Update Stable isotope"

    assert_text "Stable isotope was successfully updated"
    click_on "Back"
  end

  test "should destroy Stable isotope" do
    visit stable_isotope_url(@stable_isotope)
    click_on "Destroy this stable isotope", match: :first

    assert_text "Stable isotope was successfully destroyed"
  end
end
