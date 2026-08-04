class Article < ApplicationRecord
  # 搜索功能
  scope :search_by_keyword, ->(query) {
    if query.present?
      where("title LIKE :q OR content LIKE :q", q: "%#{query}%")
    end
  }
end