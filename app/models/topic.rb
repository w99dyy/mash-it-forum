class Topic < ApplicationRecord
  include Pinnable

  extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  belongs_to :user
  has_many :posts, dependent: :destroy
  validates :title, presence: { message: "cannot be blank!" },
                    length: {
                      minimum: 5,
                      maximum: 100,
                      too_short: "must be at least %{count} characters long",
                      too_long: "cannot exceed %{count} characters"
                    }
  acts_as_taggable_on :tags

  scope :by_tag, ->(tag) { tagged_with(tag) if tag.present? }
end
