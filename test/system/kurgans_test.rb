require 'application_system_test_case'

class KurgansTest < ApplicationSystemTestCase
  setup do
    @kurgan = kurgans(:one)
  end

  test 'visiting the index' do
    visit kurgans_url
    assert_selector 'h1', text: 'Kurgans'
  end

  test 'should create kurgan' do
    visit kurgans_url
    click_on 'New kurgan'

    fill_in 'Height', with: @kurgan.height
    fill_in 'Name', with: @kurgan.name
    fill_in 'Width', with: @kurgan.width
    click_on 'Create Kurgan'

    assert_text 'Kurgan was successfully created'
    click_on 'Back'
  end

  test 'should update Kurgan' do
    visit kurgan_url(@kurgan)
    click_on 'Edit this kurgan', match: :first

    fill_in 'Height', with: @kurgan.height
    fill_in 'Name', with: @kurgan.name
    fill_in 'Width', with: @kurgan.width
    click_on 'Update Kurgan'

    assert_text 'Kurgan was successfully updated'
    click_on 'Back'
  end

  test 'should destroy Kurgan' do
    visit kurgan_url(@kurgan)
    click_on 'Destroy this kurgan', match: :first

    assert_text 'Kurgan was successfully destroyed'
  end
end
