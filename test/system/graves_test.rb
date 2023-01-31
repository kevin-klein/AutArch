require 'application_system_test_case'

class GravesTest < ApplicationSystemTestCase
  setup do
    @grafe = graves(:one)
  end

  test 'visiting the index' do
    visit graves_url
    assert_selector 'h1', text: 'Graves'
  end

  test 'should create grave' do
    visit graves_url
    click_on 'New grave'

    fill_in 'Figure', with: @grafe.figure_id
    fill_in 'Location', with: @grafe.location
    click_on 'Create Grave'

    assert_text 'Grave was successfully created'
    click_on 'Back'
  end

  test 'should update Grave' do
    visit grafe_url(@grafe)
    click_on 'Edit this grave', match: :first

    fill_in 'Figure', with: @grafe.figure_id
    fill_in 'Location', with: @grafe.location
    click_on 'Update Grave'

    assert_text 'Grave was successfully updated'
    click_on 'Back'
  end

  test 'should destroy Grave' do
    visit grafe_url(@grafe)
    click_on 'Destroy this grave', match: :first

    assert_text 'Grave was successfully destroyed'
  end
end
