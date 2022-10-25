require "application_system_test_case"

class PageImagesTest < ApplicationSystemTestCase
  setup do
    @page_image = page_images(:one)
  end

  test "visiting the index" do
    visit page_images_url
    assert_selector "h1", text: "Page images"
  end

  test "should create page image" do
    visit page_images_url
    click_on "New page image"

    fill_in "Data", with: @page_image.data
    fill_in "Page", with: @page_image.page_id
    click_on "Create Page image"

    assert_text "Page image was successfully created"
    click_on "Back"
  end

  test "should update Page image" do
    visit page_image_url(@page_image)
    click_on "Edit this page image", match: :first

    fill_in "Data", with: @page_image.data
    fill_in "Page", with: @page_image.page_id
    click_on "Update Page image"

    assert_text "Page image was successfully updated"
    click_on "Back"
  end

  test "should destroy Page image" do
    visit page_image_url(@page_image)
    click_on "Destroy this page image", match: :first

    assert_text "Page image was successfully destroyed"
  end
end
