require "test_helper"

class ApiCorsTest < ActionDispatch::IntegrationTest
  test "allows a configured origin to access the api" do
    process :options,
      "/api/articles",
      headers: {
        "Origin" => "http://localhost:3000",
        "Access-Control-Request-Method" => "GET"
      }

    assert_response :success
    assert_equal "http://localhost:3000", response.headers["Access-Control-Allow-Origin"]
    assert_includes response.headers["Access-Control-Allow-Methods"], "GET"
  end

  test "does not add cors headers for an unconfigured origin" do
    process :options,
      "/api/articles",
      headers: {
        "Origin" => "https://not-allowed.example",
        "Access-Control-Request-Method" => "GET"
      }

    assert_nil response.headers["Access-Control-Allow-Origin"]
  end
end
