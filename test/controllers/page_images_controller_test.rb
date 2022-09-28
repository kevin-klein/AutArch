require "test_helper"

class PageImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @page_image = page_images(:one)
  end

  test "should get index" do
    get page_images_url
    assert_response :success
  end

  test "should get new" do
    get new_page_image_url
    assert_response :success
  end

  test "should create page_image" do
    assert_difference("PageImage.count") do
      post page_images_url, params: { page_image: { np_array_bytes: @page_image.np_array_bytes } }
    end

    assert_redirected_to page_image_url(PageImage.last)
  end

  test "should show page_image" do
    get page_image_url(@page_image)
    assert_response :success
  end

  test "should get edit" do
    get edit_page_image_url(@page_image)
    assert_response :success
  end

  test "should update page_image" do
    patch page_image_url(@page_image), params: { page_image: { np_array_bytes: @page_image.np_array_bytes } }
    assert_redirected_to page_image_url(@page_image)
  end

  test "should destroy page_image" do
    assert_difference("PageImage.count", -1) do
      delete page_image_url(@page_image)
    end

    assert_redirected_to page_images_url
  end
end
