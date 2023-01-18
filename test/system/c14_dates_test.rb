require "application_system_test_case"

class C14DatesTest < ApplicationSystemTestCase
  setup do
    @c14_date = c14_dates(:one)
  end

  test "visiting the index" do
    visit c14_dates_url
    assert_selector "h1", text: "C14 dates"
  end

  test "should create c14 date" do
    visit c14_dates_url
    click_on "New c14 date"

    fill_in "Age bp", with: @c14_date.age_bp
    fill_in "C14 type", with: @c14_date.c14_type
    fill_in "Cal method", with: @c14_date.cal_method
    fill_in "Calbc 1 sigma min", with: @c14_date.calbc_1_sigma_min
    fill_in "Calbc 1sigma max", with: @c14_date.calbc_1sigma_max
    fill_in "Calbc 2sigma max", with: @c14_date.calbc_2sigma_max
    fill_in "Calbc 2sigma min", with: @c14_date.calbc_2sigma_min
    fill_in "Date note", with: @c14_date.date_note
    fill_in "Interval", with: @c14_date.interval
    fill_in "Lab", with: @c14_date.lab_id
    fill_in "Material", with: @c14_date.material
    fill_in "Ref 14c", with: @c14_date.ref_14c
    click_on "Create C14 date"

    assert_text "C14 date was successfully created"
    click_on "Back"
  end

  test "should update C14 date" do
    visit c14_date_url(@c14_date)
    click_on "Edit this c14 date", match: :first

    fill_in "Age bp", with: @c14_date.age_bp
    fill_in "C14 type", with: @c14_date.c14_type
    fill_in "Cal method", with: @c14_date.cal_method
    fill_in "Calbc 1 sigma min", with: @c14_date.calbc_1_sigma_min
    fill_in "Calbc 1sigma max", with: @c14_date.calbc_1sigma_max
    fill_in "Calbc 2sigma max", with: @c14_date.calbc_2sigma_max
    fill_in "Calbc 2sigma min", with: @c14_date.calbc_2sigma_min
    fill_in "Date note", with: @c14_date.date_note
    fill_in "Interval", with: @c14_date.interval
    fill_in "Lab", with: @c14_date.lab_id
    fill_in "Material", with: @c14_date.material
    fill_in "Ref 14c", with: @c14_date.ref_14c
    click_on "Update C14 date"

    assert_text "C14 date was successfully updated"
    click_on "Back"
  end

  test "should destroy C14 date" do
    visit c14_date_url(@c14_date)
    click_on "Destroy this c14 date", match: :first

    assert_text "C14 date was successfully destroyed"
  end
end
