class Response < ApplicationRecord
  belongs_to :user
  belongs_to :query
  has_many :response_tags, dependent: :destroy
  has_many :tags, through: :response_tags

  # Validations
  validates :content, presence: true
end
