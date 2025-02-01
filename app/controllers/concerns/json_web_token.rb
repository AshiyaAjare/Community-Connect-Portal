module JsonWebToken
  SECRET_KEY = Rails.application.credentials.secret_key_base

  def self.encode(payload, exp = 7.days.from_now)
    payload[:exp] = exp.to_i
    payload[:user_id] = payload[:user_id] # Ensure user_id is included
    JWT.encode(payload, SECRET_KEY)
  end
  

  def self.decode(token)
    begin
      decoded = JWT.decode(token, SECRET_KEY)
      # Log the decoded token to debug
      Rails.logger.info("Decoded token: #{decoded}")
      HashWithIndifferentAccess.new(decoded[0])
    rescue JWT::DecodeError => e
      Rails.logger.error("JWT Decode Error: #{e.message}")
      nil
    end
  end
end
