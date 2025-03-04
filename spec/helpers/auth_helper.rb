module AuthHelper
    def auth_headers(user)
      token = JsonWebToken.encode(user_id: user.id) # Assuming you have JsonWebToken module
      { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json' }
    end
  end
  