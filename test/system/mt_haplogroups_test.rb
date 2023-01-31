require 'application_system_test_case'

class MtHaplogroupsTest < ApplicationSystemTestCase
  setup do
    @mt_haplogroup = mt_haplogroups(:one)
  end

  test 'visiting the index' do
    visit mt_haplogroups_url
    assert_selector 'h1', text: 'Mt haplogroups'
  end

  test 'should create mt haplogroup' do
    visit mt_haplogroups_url
    click_on 'New mt haplogroup'

    fill_in 'Name', with: @mt_haplogroup.name
    click_on 'Create Mt haplogroup'

    assert_text 'Mt haplogroup was successfully created'
    click_on 'Back'
  end

  test 'should update Mt haplogroup' do
    visit mt_haplogroup_url(@mt_haplogroup)
    click_on 'Edit this mt haplogroup', match: :first

    fill_in 'Name', with: @mt_haplogroup.name
    click_on 'Update Mt haplogroup'

    assert_text 'Mt haplogroup was successfully updated'
    click_on 'Back'
  end

  test 'should destroy Mt haplogroup' do
    visit mt_haplogroup_url(@mt_haplogroup)
    click_on 'Destroy this mt haplogroup', match: :first

    assert_text 'Mt haplogroup was successfully destroyed'
  end
end
