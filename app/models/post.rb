class Post < ApplicationRecord
    belongs_to :topic
    belongs_to :user
    has_many :comments, dependent: :destroy
    has_rich_text :body
    has_many_attached :images
    acts_as_taggable_on :tags, :subjects
    has_one_attached :avatar
    has_one_attached :image

    def image_preview
      image.variant(resize_to_fit: [ 150, 150 ])
    end

      scope :by_tag, ->(tag) { tagged_with(tag) if tag.present? }


    validates :title, :body, presence: true
end
