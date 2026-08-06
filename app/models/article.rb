class Article < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_one_attached :cover_image
  has_rich_text :rich_content

  scope :search_by_keyword, ->(query) {
    if query.present?
      where("title LIKE :q OR content LIKE :q", q: "%#{query}%")
    else
      all
    end
  }

  validates :title, presence: true
  validate :content_or_image_present

  private

  def content_or_image_present
    has_text = rich_content&.body&.to_plain_text.to_s.strip.present?
    has_embedded_image = rich_content&.embeds&.attached?

    return if has_text || has_embedded_image || cover_image.attached?

    errors.add(:base, "请填写文章正文或上传至少一张图片")
  end
end
