require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  test "accepts text-only content" do
    article = Article.new(title: "纯文字", rich_content: "只有文字也能发布")

    assert article.valid?
  end

  test "accepts image-only content" do
    article = Article.new(title: "纯图片")
    article.cover_image.attach(
      io: File.open(Rails.root.join("public/icon.png")),
      filename: "icon.png",
      content_type: "image/png"
    )

    assert article.valid?
  end

  test "rejects an article without text or image" do
    article = Article.new(title: "空文章")

    assert_not article.valid?
    assert_includes article.errors[:base], "请填写文章正文或上传至少一张图片"
  end
end
