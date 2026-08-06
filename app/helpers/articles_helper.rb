module ArticlesHelper
  def article_preview_image(article)
    return article.cover_image if article.cover_image.attached?

    article.rich_content.embeds.detect(&:image?)
  end
end
