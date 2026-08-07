require "test_helper"

class Api::ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "index returns paginated articles and comment counts" do
    get api_articles_url, params: { page: 1, per_page: 1 }, as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal 1, body["articles"].length
    assert body["articles"].first.key?("comments_count")
    assert_equal 1, body.dig("pagination", "current_page")
    assert_equal 1, body.dig("pagination", "per_page")
  end

  test "show returns an article" do
    get api_article_url(articles(:one)), as: :json

    assert_response :success
    assert_equal articles(:one).id, response.parsed_body.dig("article", "id")
  end
end
