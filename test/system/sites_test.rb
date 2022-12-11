require "application_system_test_case"

class SitesTest < ApplicationSystemTestCase
  setup do
    @site = sites(:one)
  end

  test "visiting the index" do
    visit sites_url
    assert_selector "h1", text: "Sites"
  end

  test "should create site" do
    visit sites_url
    click_on "New site"

    fill_in "Lat", with: @site.lat
    fill_in "Lon", with: @site.lon
    fill_in "Name", with: @site.name
    click_on "Create Site"

    assert_text "Site was successfully created"
    click_on "Back"
  end

  test "should update Site" do
    visit site_url(@site)
    click_on "Edit this site", match: :first

    fill_in "Lat", with: @site.lat
    fill_in "Lon", with: @site.lon
    fill_in "Name", with: @site.name
    click_on "Update Site"

    assert_text "Site was successfully updated"
    click_on "Back"
  end

  test "should destroy Site" do
    visit site_url(@site)
    click_on "Destroy this site", match: :first

    assert_text "Site was successfully destroyed"
  end
end
