class Tag < ApplicationRecord

  include Discard::Model

  has_many :query_tags, dependent: :destroy
  has_many :queries, through: :query_tags
  has_many :response_tags, dependent: :destroy
  has_many :responses, through: :response_tags

  validates :name, presence: true, uniqueness: true
end