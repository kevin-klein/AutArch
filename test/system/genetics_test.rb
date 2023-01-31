require 'application_system_test_case'

class GeneticsTest < ApplicationSystemTestCase
  setup do
    @genetic = genetics(:one)
  end

  test 'visiting the index' do
    visit genetics_url
    assert_selector 'h1', text: 'Genetics'
  end

  test 'should create genetic' do
    visit genetics_url
    click_on 'New genetic'

    fill_in 'Data type', with: @genetic.data_type
    fill_in 'End content', with: @genetic.end_content
    fill_in 'Ref gen', with: @genetic.ref_gen
    fill_in 'Skeleton', with: @genetic.skeleton_id
    click_on 'Create Genetic'

    assert_text 'Genetic was successfully created'
    click_on 'Back'
  end

  test 'should update Genetic' do
    visit genetic_url(@genetic)
    click_on 'Edit this genetic', match: :first

    fill_in 'Data type', with: @genetic.data_type
    fill_in 'End content', with: @genetic.end_content
    fill_in 'Ref gen', with: @genetic.ref_gen
    fill_in 'Skeleton', with: @genetic.skeleton_id
    click_on 'Update Genetic'

    assert_text 'Genetic was successfully updated'
    click_on 'Back'
  end

  test 'should destroy Genetic' do
    visit genetic_url(@genetic)
    click_on 'Destroy this genetic', match: :first

    assert_text 'Genetic was successfully destroyed'
  end
end
