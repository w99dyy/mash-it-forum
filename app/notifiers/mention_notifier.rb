# To deliver this notification:
#
# MentionNotifier.with(record: @post, message: "New post").deliver(User.all)

class MentionNotifier < ApplicationNotifier
  # Add your delivery methods
  #
  # deliver_by :email do |config|
  #   config.mailer = "UserMailer"
  #   config.method = "new_post"
  # end
  #
  # bulk_deliver_by :slack do |config|
  #   config.url = -> { Rails.application.credentials.slack_webhook_url }
  # end
  #
  # deliver_by :custom do |config|
  #   config.class = "MyDeliveryMethod"
  # end

  # Add required params
  #
  # required_param :message

  # Compute recipients without having to pass them in
  #
  # recipients do
  #   params[:record].thread.all_authors
  # end

  notification_methods do
    def actor
      params[:mentioner].user
    end

    def comment
      params[:comment]
    end

    def action
      "mention"
    end
  end
end
