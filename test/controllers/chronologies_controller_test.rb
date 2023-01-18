require "test_helper"

class ChronologiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @chronology = chronologies(:one)
  end

  test "should get index" do
    get chronologies_url
    assert_response :success
  end

  test "should get new" do
    get new_chronology_url
    assert_response :success
  end

  test "should create chronology" do
    assert_difference("Chronology.count") do
      post chronologies_url, params: { chronology: { context_from: @chronology.context_from, context_to: @chronology.context_to, period: @chronology.period } }
    end

    assert_redirected_to chronology_url(Chronology.last)
  end

  test "should show chronology" do
    get chronology_url(@chronology)
    assert_response :success
  end

  test "should get edit" do
    get edit_chronology_url(@chronology)
    assert_response :success
  end

  test "should update chronology" do
    patch chronology_url(@chronology), params: { chronology: { context_from: @chronology.context_from, context_to: @chronology.context_to, period: @chronology.period } }
    assert_redirected_to chronology_url(@chronology)
  end

  test "should destroy chronology" do
    assert_difference("Chronology.count", -1) do
      delete chronology_url(@chronology)
    end

    assert_redirected_to chronologies_url
  end
end
