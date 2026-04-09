require "net/http"
require "json"

class ApplicationController < ActionController::Base
  before_action :store_user_location!, if: :storable_location?
  before_action :sync_mashit_avatar

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?

  def require_admin!
    redirect_to root_path, alert: "Not authorized." unless current_user&.admin?
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  protected

  def authenticate_user!
    unless user_signed_in?
      redirect_to sign_in_path, alert: "You need to sign up before continuing."
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :email, :password, :password_confirmation ])
    devise_parameter_sanitizer.permit(:sign_in, keys: [ :login, :email, :password, :remember_me ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :email, :password, :password_confirmation, :current_password ])
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

   def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || super
  end

  private

  def sync_mashit_avatar
      return unless user_signed_in? && current_user.wallet_connected?
      # refetch every 5 minutes if user changed his avatar
      return if current_user.mashit_avatar_synced_at&.> 5.minutes.ago

      avatar_layers = fetch_latest_mashit(current_user.wallet_address)

      if avatar_layers
        current_user.update_columns(
          mashit_avatar_url: avatar_layers.to_json,
          mashit_avatar_synced_at: Time.current
        )
      end
    end

    def fetch_latest_mashit(wallet_address)
      uri = URI("#{MASHIT_API_URL}?wallet=#{wallet_address}")
      response = Net::HTTP.get_response(uri)
      data = JSON.parse(response.body)
      data["assets"]
    rescue => e
      Rails.logger.error "❌ Mashit fetch failed: #{e.message}"
      nil
    end

    MASHIT_API_URL = "https://avatar-artists-guild.web.app/api/mashers/latest"
end
