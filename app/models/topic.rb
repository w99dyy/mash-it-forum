class Topic < ApplicationRecord
  include Pinnable

  LAYOUTS = %w[default gallery].freeze

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
  validate :user_must_be_admin
  validates :layout, inclusion: { in: LAYOUTS }
  after_initialize :set_default_layout

  scope :by_tag, ->(tag) { tagged_with(tag) if tag.present? }
  def gallery?
    layout == "gallery"
  end

  def set_default_layout
    self.layout ||= "default"
  end

  private

  def user_must_be_admin
    errors.add(:user, "must be admin!") unless user.admin?
  end
end
