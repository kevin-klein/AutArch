require 'test_helper'

class KurgansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @kurgan = kurgans(:one)
  end

  test 'should get index' do
    get kurgans_url
    assert_response :success
  end

  test 'should get new' do
    get new_kurgan_url
    assert_response :success
  end

  test 'should create kurgan' do
    assert_difference('Kurgan.count') do
      post kurgans_url, params: { kurgan: { height: @kurgan.height, name: @kurgan.name, width: @kurgan.width } }
    end

    assert_redirected_to kurgan_url(Kurgan.last)
  end

  test 'should show kurgan' do
    get kurgan_url(@kurgan)
    assert_response :success
  end

  test 'should get edit' do
    get edit_kurgan_url(@kurgan)
    assert_response :success
  end

  test 'should update kurgan' do
    patch kurgan_url(@kurgan), params: { kurgan: { height: @kurgan.height, name: @kurgan.name, width: @kurgan.width } }
    assert_redirected_to kurgan_url(@kurgan)
  end

  test 'should destroy kurgan' do
    assert_difference('Kurgan.count', -1) do
      delete kurgan_url(@kurgan)
    end

    assert_redirected_to kurgans_url
  end
end
