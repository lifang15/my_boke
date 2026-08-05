class Comment < ApplicationRecord
  belongs_to :article
  validates :commenter, presence: { message: "昵称不能为空" }
  validates :body, presence: { message: "内容不能为空" }
end
