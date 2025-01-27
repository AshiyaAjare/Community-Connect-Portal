class User < ApplicationRecord
    enum role: {contributor: 0, moderator: 1, admin: 2}
    has_many :query, dependent: :destroy
    has_many :responses, dependent: :destroy

    validates :first_name, presence: true, length: { maximum: 50 }
    validates :last_name, presence: true, length: { maximum: 50 }
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, presence: true, length: { minimum: 6 }, if: :password_digest_changed?
    # Secure password functionality (requires bcrypt gem)
    has_secure_password

    def profile_image
        profile_image_url.presence || 'https://www.gravatar.com/avatar/3b3be63a4c2a439b013787725dfce802?d=identicon'
    end

end
