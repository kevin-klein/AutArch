require 'application_system_test_case'

class PublicationsTest < ApplicationSystemTestCase
  setup do
    @publication = publications(:one)
  end

  test 'visiting the index' do
    visit publications_url
    assert_selector 'h1', text: 'Publications'
  end

  test 'should create publication' do
    visit publications_url
    click_on 'New publication'

    fill_in 'Author', with: @publication.author
    fill_in 'Pdf', with: @publication.pdf
    fill_in 'Title', with: @publication.title
    click_on 'Create Publication'

    assert_text 'Publication was successfully created'
    click_on 'Back'
  end

  test 'should update Publication' do
    visit publication_url(@publication)
    click_on 'Edit this publication', match: :first

    fill_in 'Author', with: @publication.author
    fill_in 'Pdf', with: @publication.pdf
    fill_in 'Title', with: @publication.title
    click_on 'Update Publication'

    assert_text 'Publication was successfully updated'
    click_on 'Back'
  end

  test 'should destroy Publication' do
    visit publication_url(@publication)
    click_on 'Destroy this publication', match: :first

    assert_text 'Publication was successfully destroyed'
  end
end
