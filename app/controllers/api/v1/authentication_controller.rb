class Api::V1::AuthenticationController < Api::V1::BaseController
  skip_before_action :authenticate_request, only: [:login] # Skip JWT authentication for login

  respond_to :json

  def login
    user = User.find_by(email: params[:email])

    # Check if the email and password match
    if user&.valid_password?(params[:password])
      # Generate JWT token and send it to the client
      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token, user: { id: user.id, email: user.email } }, status: :ok
    else
      # If authentication fails
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
end
