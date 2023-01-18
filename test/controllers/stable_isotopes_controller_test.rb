require "test_helper"

class StableIsotopesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @stable_isotope = stable_isotopes(:one)
  end

  test "should get index" do
    get stable_isotopes_url
    assert_response :success
  end

  test "should get new" do
    get new_stable_isotope_url
    assert_response :success
  end

  test "should create stable_isotope" do
    assert_difference("StableIsotope.count") do
      post stable_isotopes_url, params: { stable_isotope: { baseline: @stable_isotope.baseline, iso_bone: @stable_isotope.iso_bone, iso_id: @stable_isotope.iso_id, iso_value: @stable_isotope.iso_value, isotope: @stable_isotope.isotope, ref_iso: @stable_isotope.ref_iso, skeleton_id: @stable_isotope.skeleton_id } }
    end

    assert_redirected_to stable_isotope_url(StableIsotope.last)
  end

  test "should show stable_isotope" do
    get stable_isotope_url(@stable_isotope)
    assert_response :success
  end

  test "should get edit" do
    get edit_stable_isotope_url(@stable_isotope)
    assert_response :success
  end

  test "should update stable_isotope" do
    patch stable_isotope_url(@stable_isotope), params: { stable_isotope: { baseline: @stable_isotope.baseline, iso_bone: @stable_isotope.iso_bone, iso_id: @stable_isotope.iso_id, iso_value: @stable_isotope.iso_value, isotope: @stable_isotope.isotope, ref_iso: @stable_isotope.ref_iso, skeleton_id: @stable_isotope.skeleton_id } }
    assert_redirected_to stable_isotope_url(@stable_isotope)
  end

  test "should destroy stable_isotope" do
    assert_difference("StableIsotope.count", -1) do
      delete stable_isotope_url(@stable_isotope)
    end

    assert_redirected_to stable_isotopes_url
  end
end
