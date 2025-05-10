class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :invitable

  require "securerandom"
    
  include Discard::Model

  

  enum role: {contributor: 0, moderator: 1, admin_user: 2}
  has_many :queries, dependent: :destroy
  has_many :responses, dependent: :destroy
  has_one_attached :profile_image

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  def display_profile_image_url
    if profile_image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(profile_image, only_path: true)
    else
      profile_image_url.presence || 'https://www.gravatar.com/avatar/3b3be63a4c2a439b013787725dfce802?d=identicon'
    end
  end

  before_invitation_created :set_default_role

  private

  def set_default_role
    self.role ||= :contributor
  end
  

end
