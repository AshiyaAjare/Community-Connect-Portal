class Query < ApplicationRecord
  include Discard::Model

  belongs_to :user
  has_many :responses, -> { kept }, dependent: :destroy
  has_many :query_tags, dependent: :destroy
  has_many :tags, through: :query_tags

  # Validations
  validates :content, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :title, presence: true, length: { maximum: 255 }
  
end