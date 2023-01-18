require "test_helper"

class CulturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @culture = cultures(:one)
  end

  test "should get index" do
    get cultures_url
    assert_response :success
  end

  test "should get new" do
    get new_culture_url
    assert_response :success
  end

  test "should create culture" do
    assert_difference("Culture.count") do
      post cultures_url, params: { culture: { name: @culture.name } }
    end

    assert_redirected_to culture_url(Culture.last)
  end

  test "should show culture" do
    get culture_url(@culture)
    assert_response :success
  end

  test "should get edit" do
    get edit_culture_url(@culture)
    assert_response :success
  end

  test "should update culture" do
    patch culture_url(@culture), params: { culture: { name: @culture.name } }
    assert_redirected_to culture_url(@culture)
  end

  test "should destroy culture" do
    assert_difference("Culture.count", -1) do
      delete culture_url(@culture)
    end

    assert_redirected_to cultures_url
  end
end
