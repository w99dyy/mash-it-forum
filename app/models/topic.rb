class Topic < ApplicationRecord
  belongs_to :user
  has_many :posts, dependent: :destroy
  validates :title, presence: true
  acts_as_taggable_on :tags
end
