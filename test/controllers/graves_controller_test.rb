require "test_helper"

class GravesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @grafe = graves(:one)
  end

  test "should get index" do
    get graves_url
    assert_response :success
  end

  test "should get new" do
    get new_grafe_url
    assert_response :success
  end

  test "should create grafe" do
    assert_difference("Grave.count") do
      post graves_url, params: { grafe: { figure_id: @grafe.figure_id, location: @grafe.location } }
    end

    assert_redirected_to grafe_url(Grave.last)
  end

  test "should show grafe" do
    get grafe_url(@grafe)
    assert_response :success
  end

  test "should get edit" do
    get edit_grafe_url(@grafe)
    assert_response :success
  end

  test "should update grafe" do
    patch grafe_url(@grafe), params: { grafe: { figure_id: @grafe.figure_id, location: @grafe.location } }
    assert_redirected_to grafe_url(@grafe)
  end

  test "should destroy grafe" do
    assert_difference("Grave.count", -1) do
      delete grafe_url(@grafe)
    end

    assert_redirected_to graves_url
  end
end
