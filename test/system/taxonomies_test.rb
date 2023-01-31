require 'application_system_test_case'

class TaxonomiesTest < ApplicationSystemTestCase
  setup do
    @taxonomy = taxonomies(:one)
  end

  test 'visiting the index' do
    visit taxonomies_url
    assert_selector 'h1', text: 'Taxonomies'
  end

  test 'should create taxonomy' do
    visit taxonomies_url
    click_on 'New taxonomy'

    fill_in 'Culture', with: @taxonomy.culture
    fill_in 'Culture note', with: @taxonomy.culture_note
    fill_in 'Culture reference', with: @taxonomy.culture_reference
    click_on 'Create Taxonomy'

    assert_text 'Taxonomy was successfully created'
    click_on 'Back'
  end

  test 'should update Taxonomy' do
    visit taxonomy_url(@taxonomy)
    click_on 'Edit this taxonomy', match: :first

    fill_in 'Culture', with: @taxonomy.culture
    fill_in 'Culture note', with: @taxonomy.culture_note
    fill_in 'Culture reference', with: @taxonomy.culture_reference
    click_on 'Update Taxonomy'

    assert_text 'Taxonomy was successfully updated'
    click_on 'Back'
  end

  test 'should destroy Taxonomy' do
    visit taxonomy_url(@taxonomy)
    click_on 'Destroy this taxonomy', match: :first

    assert_text 'Taxonomy was successfully destroyed'
  end
end
