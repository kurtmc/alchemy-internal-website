require 'test_helper'

class AgenciesControllerTest < ActionController::TestCase
  setup do
    @agency = agencies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:agencies)
  end

  # Agencies are basically read only
  test "should get new" do
  end

  # Agencies are not created, they come from Navision
  test "should create agency" do
  end

  test "should show agency" do
    get :show, id: @agency
    assert_response :success
  end

  # Agencies are basically read only
  test "should get edit" do
  end

  # Agencies are basically read only
  test "should update agency" do
  end

  # Agencies are basically read only
  test "should destroy agency" do
  end
end
