module ArticlesHelper
  def article_preview_image(article)
    return article.cover_image if article.cover_image.attached?

    article.rich_content.embeds.detect(&:image?)
  end

  def article_preview_variant(article)
    image = article_preview_image(article)
    return unless image

    image.variant(
      resize_to_fill: [ 520, 360 ],
      format: :webp,
      saver: { quality: 76, strip: true }
    )
  end

  def article_cover_variant(article)
    return unless article.cover_image.attached?

    article.cover_image.variant(
      resize_to_limit: [ 1600, 1200 ],
      format: :webp,
      saver: { quality: 82, strip: true }
    )
  end
end
