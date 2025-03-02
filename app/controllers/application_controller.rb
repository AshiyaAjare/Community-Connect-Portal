class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  

  allow_browser versions: :modern
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  before_action :authenticate_user!, unless: :devise_controller?

  #rescue_from User::Unauthorized, with: :user_not_authenticated


  protected

  # Allow additional parameters in Devise (if needed)
  def after_sign_in_path_for(resource)
    resource.admin_user? ? users_path : root_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email, :password, :role, :profile_image])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :email, :password, :current_password, :role, :profile_image])
  end


  def authenticate_user!
  Rails.logger.debug "Checking authentication..."
  
  origin = request.origin || request.referer # Get the request source
  Rails.logger.debug "Request Origin: #{origin}"

  if request.format.html? || request.format.turbo_stream?
    # For web requests, redirect to sign-in if the user is not authenticated
    unless user_signed_in?
      Rails.logger.debug "Redirecting to sign-in..."
      redirect_to new_user_session_path and return
    end

  else
    # For API requests, check JWT token authentication
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    if token.blank?
      render json: { error: 'Token missing' }, status: :unauthorized and return
    end

    decoded_token = JsonWebToken.decode(token)

    if decoded_token.nil? || decoded_token[:user_id].nil?
      render json: { error: 'Invalid token' }, status: :unauthorized and return
    end

    @current_user = User.find_by(id: decoded_token[:user_id])

    if @current_user.nil?
      render json: { error: 'Unauthorized' }, status: :unauthorized and return
    end

    if origin == "http://localhost:3000" && !@current_user.admin_user?
      render json: { error: 'Access denied' }, status: :forbidden and return
    elsif origin == "http://localhost:5173" && @current_user.admin_user?
      render json: { error: 'Admins cannot log in from frontend' }, status: :forbidden and return
    end
  end
 end


  def after_sign_up_path_for(resource)
    sign_out resource # Ensure the newly created user is logged out immediately
    users_path # Redirect to the users list or any other admin page
  end
  

end
