class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  

  allow_browser versions: :modern
  protect_from_forgery with: :null_session

  before_action :authenticate_user!, unless: :devise_controller?

  #rescue_from User::Unauthorized, with: :user_not_authenticated


  protected

  # Allow additional parameters in Devise (if needed)
  def after_sign_in_path_for(resource)
    resource.admin_user? ? users_path : root_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end


  def authenticate_user!
    Rails.logger.debug "Checking authentication..."
    
    if request.format.html?
      # For web requests, redirect to sign-in if the user is not authenticated
      unless user_signed_in?
        Rails.logger.debug "Redirecting to sign-in..."
        redirect_to new_user_session_path and return
      end
    else
      # For API requests, return JSON unauthorized error instead of redirecting
      unless user_signed_in?
        render json: { error: "You need to sign in or sign up before continuing." }, status: :unauthorized
      end
    end
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end
  

end
