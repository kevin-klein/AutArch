require "test_helper"

class MtHaplogroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mt_haplogroup = mt_haplogroups(:one)
  end

  test "should get index" do
    get mt_haplogroups_url
    assert_response :success
  end

  test "should get new" do
    get new_mt_haplogroup_url
    assert_response :success
  end

  test "should create mt_haplogroup" do
    assert_difference("MtHaplogroup.count") do
      post mt_haplogroups_url, params: { mt_haplogroup: { name: @mt_haplogroup.name } }
    end

    assert_redirected_to mt_haplogroup_url(MtHaplogroup.last)
  end

  test "should show mt_haplogroup" do
    get mt_haplogroup_url(@mt_haplogroup)
    assert_response :success
  end

  test "should get edit" do
    get edit_mt_haplogroup_url(@mt_haplogroup)
    assert_response :success
  end

  test "should update mt_haplogroup" do
    patch mt_haplogroup_url(@mt_haplogroup), params: { mt_haplogroup: { name: @mt_haplogroup.name } }
    assert_redirected_to mt_haplogroup_url(@mt_haplogroup)
  end

  test "should destroy mt_haplogroup" do
    assert_difference("MtHaplogroup.count", -1) do
      delete mt_haplogroup_url(@mt_haplogroup)
    end

    assert_redirected_to mt_haplogroups_url
  end
end
