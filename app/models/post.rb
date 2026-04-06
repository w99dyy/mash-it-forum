class Post < ApplicationRecord
    include Pinnable
    after_create :notify_discord
    belongs_to :topic, counter_cache: true
    belongs_to :user
    has_many :comments, dependent: :destroy
    has_rich_text :body
    has_many_attached :images
    acts_as_taggable_on :tags, :subjects
    has_one_attached :avatar
    has_one_attached :cover_image

    def thumbnail
      body.embeds.attachments.first&.blob
    end

    scope :by_tag, ->(tag) { tagged_with(tag) if tag.present? }


  validates :title, presence: { message: "cannot be blank!" },
                    length: {
                      minimum: 5,
                      maximum: 100,
                      too_short: "must be at least %{count} characters long",
                      too_long: "cannot exceed %{count} characters"
                    }
  validates :body, presence: true

  validate :has_tags

  validate :topic_not_locked, on: :create

  private

  def notify_discord
    # Run in background to avoid slowing down response
    DiscordNotifier.post_created(self)
  end

  def topic_not_locked
    errors.add(:base, "This topic is locked.") if topic.locked?
  end

  def has_tags
    if tag_list.empty?
      errors.add(:base, "Tags can't be blank")
    end
  end
end
