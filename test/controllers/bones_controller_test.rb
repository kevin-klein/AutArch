require "test_helper"

class BonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bone = bones(:one)
  end

  test "should get index" do
    get bones_url
    assert_response :success
  end

  test "should get new" do
    get new_bone_url
    assert_response :success
  end

  test "should create bone" do
    assert_difference("Bone.count") do
      post bones_url, params: { bone: { name: @bone.name } }
    end

    assert_redirected_to bone_url(Bone.last)
  end

  test "should show bone" do
    get bone_url(@bone)
    assert_response :success
  end

  test "should get edit" do
    get edit_bone_url(@bone)
    assert_response :success
  end

  test "should update bone" do
    patch bone_url(@bone), params: { bone: { name: @bone.name } }
    assert_redirected_to bone_url(@bone)
  end

  test "should destroy bone" do
    assert_difference("Bone.count", -1) do
      delete bone_url(@bone)
    end

    assert_redirected_to bones_url
  end
end
