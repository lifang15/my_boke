require "test_helper"

class Api::CommentsControllerTest < ActionDispatch::IntegrationTest
  test "index returns paginated comments" do
    get api_article_comments_url(articles(:one)), params: { page: 1, per_page: 1 }, as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal 1, body["comments"].length
    assert_equal 1, body.dig("pagination", "current_page")
  end

  test "create returns the new comment" do
    assert_difference("Comment.count", 1) do
      post api_article_comments_url(articles(:one)), params: {
        comment: { commenter: "API 用户", body: "API 评论" }
      }, as: :json
    end

    assert_response :created
    assert_equal "API 用户", response.parsed_body.dig("comment", "commenter")
  end
end
