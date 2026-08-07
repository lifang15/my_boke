require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test "create redirects to the first comments page anchor" do
    article = Article.create!(title: "评论文章", rich_content: "正文")

    assert_difference("Comment.count", 1) do
      post article_comments_path(article), params: {
        comment: { commenter: "访客", body: "新评论" }
      }
    end

    assert_redirected_to article_path(article, comments_page: 1, anchor: "comments")
  end

  test "destroy redirects to the first comments page anchor" do
    article = Article.create!(title: "评论文章", rich_content: "正文")
    comment = article.comments.create!(commenter: "访客", body: "待删除评论")

    assert_difference("Comment.count", -1) do
      delete article_comment_path(article, comment)
    end

    assert_redirected_to article_path(article, comments_page: 1, anchor: "comments")
  end
end
