module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session

      include JsonWebToken

      before_action :authenticate_request

      private

      def authenticate_request
        header = request.headers['Authorization']
        token = header.split(' ').last if header

        begin
          decoded_token = JsonWebToken.jwt_decode(token)
          @current_user = User.find(decoded_token[:user_id])
        rescue ActiveRecord::RecordNotFound, JWT::DecodeError
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end
      
    end
  end
end
