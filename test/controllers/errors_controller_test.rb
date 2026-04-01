require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  VALID_STATUS_CODES = ErrorsController::VALID_STATUS_CODES

  VALID_STATUS_CODES.each do |status_code|
    test "should render #{status_code} page" do
      get "/#{status_code}"
      assert_response status_code.to_i
      assert_select "h1", status_code
    end
  end

  test "should return status code for non-html formats" do
    get "/404", as: :json
    assert_response :not_found
  end
end
