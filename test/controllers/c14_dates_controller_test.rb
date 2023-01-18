require "test_helper"

class C14DatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @c14_date = c14_dates(:one)
  end

  test "should get index" do
    get c14_dates_url
    assert_response :success
  end

  test "should get new" do
    get new_c14_date_url
    assert_response :success
  end

  test "should create c14_date" do
    assert_difference("C14Date.count") do
      post c14_dates_url, params: { c14_date: { age_bp: @c14_date.age_bp, c14_type: @c14_date.c14_type, cal_method: @c14_date.cal_method, calbc_1_sigma_min: @c14_date.calbc_1_sigma_min, calbc_1sigma_max: @c14_date.calbc_1sigma_max, calbc_2sigma_max: @c14_date.calbc_2sigma_max, calbc_2sigma_min: @c14_date.calbc_2sigma_min, date_note: @c14_date.date_note, interval: @c14_date.interval, lab_id: @c14_date.lab_id, material: @c14_date.material, ref_14c: @c14_date.ref_14c } }
    end

    assert_redirected_to c14_date_url(C14Date.last)
  end

  test "should show c14_date" do
    get c14_date_url(@c14_date)
    assert_response :success
  end

  test "should get edit" do
    get edit_c14_date_url(@c14_date)
    assert_response :success
  end

  test "should update c14_date" do
    patch c14_date_url(@c14_date), params: { c14_date: { age_bp: @c14_date.age_bp, c14_type: @c14_date.c14_type, cal_method: @c14_date.cal_method, calbc_1_sigma_min: @c14_date.calbc_1_sigma_min, calbc_1sigma_max: @c14_date.calbc_1sigma_max, calbc_2sigma_max: @c14_date.calbc_2sigma_max, calbc_2sigma_min: @c14_date.calbc_2sigma_min, date_note: @c14_date.date_note, interval: @c14_date.interval, lab_id: @c14_date.lab_id, material: @c14_date.material, ref_14c: @c14_date.ref_14c } }
    assert_redirected_to c14_date_url(@c14_date)
  end

  test "should destroy c14_date" do
    assert_difference("C14Date.count", -1) do
      delete c14_date_url(@c14_date)
    end

    assert_redirected_to c14_dates_url
  end
end
