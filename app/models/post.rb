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

  private

  def notify_discord
    # Run in background to avoid slowing down response
    DiscordNotifier.post_created(self)
  end
end
