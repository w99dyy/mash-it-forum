class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?



  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  protected



  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :email, :password, :password_confirmation ])
    devise_parameter_sanitizer.permit(:sign_in, keys: [ :login, :email, :password, :remember_me ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :email, :password, :password_confirmation, :current_password ])
  end
end
