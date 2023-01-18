require "test_helper"

class GeneticsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @genetic = genetics(:one)
  end

  test "should get index" do
    get genetics_url
    assert_response :success
  end

  test "should get new" do
    get new_genetic_url
    assert_response :success
  end

  test "should create genetic" do
    assert_difference("Genetic.count") do
      post genetics_url, params: { genetic: { data_type: @genetic.data_type, end_content: @genetic.end_content, ref_gen: @genetic.ref_gen, skeleton_id: @genetic.skeleton_id } }
    end

    assert_redirected_to genetic_url(Genetic.last)
  end

  test "should show genetic" do
    get genetic_url(@genetic)
    assert_response :success
  end

  test "should get edit" do
    get edit_genetic_url(@genetic)
    assert_response :success
  end

  test "should update genetic" do
    patch genetic_url(@genetic), params: { genetic: { data_type: @genetic.data_type, end_content: @genetic.end_content, ref_gen: @genetic.ref_gen, skeleton_id: @genetic.skeleton_id } }
    assert_redirected_to genetic_url(@genetic)
  end

  test "should destroy genetic" do
    assert_difference("Genetic.count", -1) do
      delete genetic_url(@genetic)
    end

    assert_redirected_to genetics_url
  end
end
