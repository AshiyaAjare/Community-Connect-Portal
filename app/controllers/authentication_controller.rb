class AuthenticationController < Api::V1::BaseController
    skip_before_action :authenticate_request, only: [:login] # Only skip for login
  
    def login
      @user = User.find_by(email: params[:email])
  
      if @user&.authenticate(params[:password])
        token = JsonWebToken.jwt_encode(user_id: @user.id)
        render json: { token: token }, status: :ok
      else
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
  