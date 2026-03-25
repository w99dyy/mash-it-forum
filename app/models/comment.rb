class Comment < ApplicationRecord
  after_create :send_email_notification
  belongs_to :post, counter_cache: true
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many_attached :images
  has_rich_text :body
  validates :body, presence: true

  def send_email_notification
    if parent_id.present?
      parent_author = parent.user

      if parent_author != user
        CommentMailer.with(comment: self, recipient: parent_author).reply_notification.deliver_now
      end
    else
      post_author = post.user
      if post_author != user
        CommentMailer.with(comment: self, recipient: post_author).post_comment_notification.deliver_now
      end
    end
  end
end
