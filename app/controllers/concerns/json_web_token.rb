module JsonWebToken
  PRIVATE_KEY = OpenSSL::PKey::RSA.new(File.read("private.pem"))
  PUBLIC_KEY = OpenSSL::PKey::RSA.new(File.read("public.pem"))

  def self.encode(payload, exp = 7.days.from_now)
    payload[:exp] = exp.to_i
    payload[:hash] = Digest::SHA256.hexdigest(payload.to_json)
    JWT.encode(payload, PRIVATE_KEY, 'RS256') # Use RS256
  end
  
  def self.decode(token)
    begin
      decoded = JWT.decode(token, PUBLIC_KEY, true, { algorithm: 'RS256' })[0]

      # Verify hash integrity
      expected_hash = Digest::SHA256.hexdigest(decoded.except("hash").to_json)
      if decoded["hash"] != expected_hash
        raise JWT::VerificationError, "Token payload tampered with!"
      end

      unless JWT.encode(decoded, PRIVATE_KEY, 'RS256') == token
        raise JWT::VerificationError, "Token signature mismatch!"
      end
  
      HashWithIndifferentAccess.new(decoded)
    rescue JWT::VerificationError => e
      Rails.logger.error("JWT Error: Invalid token signature or payload")
      nil
    rescue JWT::DecodeError => e
      Rails.logger.error("JWT Decode Error: #{e.message}")
      nil
    end
  end
  
  
end

  # def self.decode(token)
  #   begin
  #     decoded = JWT.decode(token, SECRET_KEY)
  #     # Log the decoded token to debug
  #     Rails.logger.info("Decoded token: #{decoded}")
  #     HashWithIndifferentAccess.new(decoded[0])
  #   rescue JWT::DecodeError => e
  #     Rails.logger.error("JWT Decode Error: #{e.message}")
  #     nil
  #   end
  # end


