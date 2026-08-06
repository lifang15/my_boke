require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "index paginates articles five at a time" do
    7.times do |number|
      Article.create!(title: "分页文章 #{number}", rich_content: "分页正文")
    end

    get articles_path(page: 1)
    assert_response :success
    assert_select ".article-card", count: 5
    assert_select ".pagination [aria-current='page']", text: "1"

    get articles_path(page: 2)
    assert_response :success
    assert_select ".article-card", count: Article.count - 5
    assert_select ".pagination [aria-current='page']", text: "2"
  end

  test "pagination keeps the current search query" do
    6.times do |number|
      Article.create!(title: "相同关键词 #{number}", rich_content: "分页正文")
    end

    get articles_path(query: "相同关键词")

    assert_response :success
    assert_select ".pagination a[href*='query=%E7%9B%B8%E5%90%8C%E5%85%B3%E9%94%AE%E8%AF%8D']"
  end

  test "renders the edit form with existing content" do
    article = Article.create!(title: "待编辑文章", rich_content: "原有正文")

    get edit_article_path(article)

    assert_response :success
    assert_select "input[name='article[title]'][value='待编辑文章']"
    assert_select "input[name='article[rich_content]'][value*='原有正文']"
    assert_select "trix-editor[input]"
  end

  test "index renders rich text and an attached image" do
    article = Article.new(title: "首页图文", rich_content: "首页摘要")
    article.cover_image.attach(
      io: File.open(Rails.root.join("public/icon.png")),
      filename: "icon.png",
      content_type: "image/png"
    )
    article.save!

    get articles_path

    assert_response :success
    assert_select ".article-card-media img[alt='首页图文']"
    assert_select ".article-summary", text: /首页摘要/
  end

  test "creates a text-only article" do
    assert_difference("Article.count", 1) do
      post articles_path, params: { article: { title: "文字文章", rich_content: "正文内容" } }
    end

    assert_redirected_to article_path(Article.order(:created_at).last)
  end

  test "creates an image-only article" do
    image = fixture_file_upload(Rails.root.join("public/icon.png"), "image/png")

    assert_difference("Article.count", 1) do
      post articles_path, params: { article: { title: "图片文章", cover_image: image, rich_content: "" } }
    end

    assert Article.order(:created_at).last.cover_image.attached?
  end

  test "creates an article containing text and an image" do
    image = fixture_file_upload(Rails.root.join("public/icon.png"), "image/png")

    assert_difference("Article.count", 1) do
      post articles_path, params: {
        article: { title: "图文文章", rich_content: "图文正文", cover_image: image }
      }
    end

    article = Article.order(:created_at).last
    assert_equal "图文正文", article.rich_content.to_plain_text
    assert article.cover_image.attached?
  end

  test "does not create an empty article" do
    assert_no_difference("Article.count") do
      post articles_path, params: { article: { title: "空文章", rich_content: "" } }
    end

    assert_response :unprocessable_entity
  end
end
