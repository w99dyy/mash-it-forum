class Post < ApplicationRecord
    include Pinnable
    after_create :notify_discord
    belongs_to :topic, counter_cache: true
    belongs_to :user
    has_many :comments, dependent: :destroy
    has_rich_text :body   
    has_many_attached :images, dependent: :perge_later
    acts_as_taggable_on :tags
    acts_as_votable
    has_one_attached :avatar

    extend FriendlyId
    friendly_id :title, use: [:slugged, :finders]

  #  def thumbnail
  #    body.embeds.attachments.first&.blob
  #  end

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

  validate :tags_must_exist

  validate :topic_not_locked, on: :create

  validate :acceptable_images

  def acceptable_images
    images.each do |image|
    unless image.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
      errors.add(:images, "must be JPEG, GIF, PNG or WebP")
    end
      if image.byte_size > 10.megabytes
        errors.add(:images, "must be less than 10MB each")
      end
    end
  end

  def tags_must_exist
    tag_list.each do |tag_name|
      unless ActsAsTaggableOn::Tag.exists?(name: tag_name)
        errors.add(:tag, "#{tag_name} is not valid")
      end
    end
  end

  # this prevents triggering updated_at when pin/unpin a post
  def pin!
    update_columns(pinned: true)
  end

  def unpin!
    update_columns(pinned: false)
  end

  private

  def notify_discord
    # Run in background to avoid slowing down response
    DiscordNotifier.post_created(self)
  end

  def topic_not_locked
    errors.add(:base, "This topic is locked.") if topic.locked? unless user.admin?
  end

  def has_tags
    if tag_list.empty?
      errors.add(:base, "Tags can't be blank")
    end
  end
end
