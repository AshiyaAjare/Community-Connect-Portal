class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  

  allow_browser versions: :modern
  protect_from_forgery with: :null_session

  before_action :authenticate_user!, unless: :devise_controller?


  protected

  # Allow additional parameters in Devise (if needed)
  def after_sign_in_path_for(resource)
    resource.admin_user? ? users_path : root_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

end
