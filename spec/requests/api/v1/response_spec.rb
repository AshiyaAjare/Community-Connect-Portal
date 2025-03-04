require 'rails_helper'

RSpec.describe Api::V1::ResponsesController, type: :request do
  let!(:user) { create(:user) } # Ensure a user exists
  let!(:query) { create(:query) }
  let!(:response_record) { create(:response, query: query, user: user) }

  

  describe 'GET /api/v1/responses' do
    it 'returns a list of responses' do
      get '/api/v1/responses', headers: auth_headers(user)

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['responses']).not_to be_empty
    end
  end

  
end
