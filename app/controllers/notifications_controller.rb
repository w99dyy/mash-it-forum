class NotificationsController < ApplicationController
    before_action :authenticate_user!

    def index
        @notifications = current_user.notifications.order(created_at: :desc).limit(20)

        respond_to do |format|
            format.html
            format.json { render json: @notifications.as_json(methods: notification_data) }
        end
    end

    def show
        @notification = current_user.notifications.find(params[:id])
        @notification.mark_as_read! unless @notification.read?

        redirect_to @notification.to_path
    end

    def mark_as_read
        @notification = current_user.notifications.find(params[:id])
        @notification.update!(read_at: Time.current)

        respond_to do |format|
        format.html { redirect_back fallback_location: notifications_path }
        format.json { render json: { success: true } }
        end
    end

    def mark_all_as_read
        current_user.notifications.unread.update_all(read_at: Time.current)

        respond_to do |format|
            format.html { redirect_back fallback_location: notifications_path }
            format.json { render json: { success: true } }
        end
    end
end
