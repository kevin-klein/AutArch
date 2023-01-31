require 'test_helper'

class AnthropologiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @anthropology = anthropologies(:one)
  end

  test 'should get index' do
    get anthropologies_url
    assert_response :success
  end

  test 'should get new' do
    get new_anthropology_url
    assert_response :success
  end

  test 'should create anthropology' do
    assert_difference('Anthropology.count') do
      post anthropologies_url,
           params: { anthropology: { age_as_reported: @anthropology.age_as_reported, age_class: @anthropology.age_class,
                                     height: @anthropology.height, pathologies: @anthropology.pathologies, pathologies_type: @anthropology.pathologies_type, sex_consensus: @anthropology.sex_consensus, sex_gen: @anthropology.sex_gen, sex_morph: @anthropology.sex_morph } }
    end

    assert_redirected_to anthropology_url(Anthropology.last)
  end

  test 'should show anthropology' do
    get anthropology_url(@anthropology)
    assert_response :success
  end

  test 'should get edit' do
    get edit_anthropology_url(@anthropology)
    assert_response :success
  end

  test 'should update anthropology' do
    patch anthropology_url(@anthropology),
          params: { anthropology: { age_as_reported: @anthropology.age_as_reported, age_class: @anthropology.age_class,
                                    height: @anthropology.height, pathologies: @anthropology.pathologies, pathologies_type: @anthropology.pathologies_type, sex_consensus: @anthropology.sex_consensus, sex_gen: @anthropology.sex_gen, sex_morph: @anthropology.sex_morph } }
    assert_redirected_to anthropology_url(@anthropology)
  end

  test 'should destroy anthropology' do
    assert_difference('Anthropology.count', -1) do
      delete anthropology_url(@anthropology)
    end

    assert_redirected_to anthropologies_url
  end
end
