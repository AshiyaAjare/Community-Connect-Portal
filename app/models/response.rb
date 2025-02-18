class Response < ApplicationRecord
  include Discard::Model
  
  belongs_to :user
  belongs_to :query
  has_many :response_tags, dependent: :destroy
  has_many :tags, through: :response_tags

  after_update :close_query_if_approved, if: -> { saved_change_to_approval?(from: false, to: true) }

  private

  def close_query_if_approved
    query.update!(status: true) # Mark query as closed
  end

  # Validations
  validates :content, presence: true
end