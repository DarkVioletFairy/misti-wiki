require "test_helper"

class Api::V1::HealthTest < ActionDispatch::IntegrationTest
  test "returns an API health response" do
    get "/api/v1/health"

    assert_response :success
    assert_equal({ "status" => "ok" }, response.parsed_body)
  end
end
