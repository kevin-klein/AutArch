require "test_helper"

class YHaplogroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @y_haplogroup = y_haplogroups(:one)
  end

  test "should get index" do
    get y_haplogroups_url
    assert_response :success
  end

  test "should get new" do
    get new_y_haplogroup_url
    assert_response :success
  end

  test "should create y_haplogroup" do
    assert_difference("YHaplogroup.count") do
      post y_haplogroups_url, params: { y_haplogroup: { name: @y_haplogroup.name } }
    end

    assert_redirected_to y_haplogroup_url(YHaplogroup.last)
  end

  test "should show y_haplogroup" do
    get y_haplogroup_url(@y_haplogroup)
    assert_response :success
  end

  test "should get edit" do
    get edit_y_haplogroup_url(@y_haplogroup)
    assert_response :success
  end

  test "should update y_haplogroup" do
    patch y_haplogroup_url(@y_haplogroup), params: { y_haplogroup: { name: @y_haplogroup.name } }
    assert_redirected_to y_haplogroup_url(@y_haplogroup)
  end

  test "should destroy y_haplogroup" do
    assert_difference("YHaplogroup.count", -1) do
      delete y_haplogroup_url(@y_haplogroup)
    end

    assert_redirected_to y_haplogroups_url
  end
end
