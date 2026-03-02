class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user
  has_many_attached :images
  has_rich_text :body
  has_one_attached :avatar

  validates :body, presence: true
end
