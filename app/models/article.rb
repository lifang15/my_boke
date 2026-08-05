class Article < ApplicationRecord
  #文章删除了，其下的评论也删除了
 has_many :comments, dependent: :destroy
 has_one_attached:cover_image
 has_rich_text :rich_content

 scope  :search_by_keyword, ->(query){
  if query.presence?
    where("title LIKE:q OR content LIKE :q", q: "%#{query}%")
  end
 }

  # 搜索功能
  scope :search_by_keyword, ->(query) {
    if query.present?
      where("title LIKE :q OR content LIKE :q", q: "%#{query}%")
    end

  }
  validates :title, presence: true
  validates :rich_content, presence: true
end
