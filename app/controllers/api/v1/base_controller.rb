module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session

      before_action :authenticate_request  # Use JWT authentication
      skip_before_action :authenticate_user!, raise: false  # Prevent Devise from blocking API requests

      respond_to :json

      private

      def authenticate_request
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
      
        render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
      end      
    end
  end
end
