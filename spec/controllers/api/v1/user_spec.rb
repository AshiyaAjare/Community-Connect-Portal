require 'rails_helper'

RSpec.describe 'API::V1::Users', type: :request do
    let(:admin) { create(:user, role: :admin_user) }
    let(:user) { create(:user) }
  
    describe 'GET /api/v1/users' do
      it 'returns all users' do
        get '/api/v1/users', headers: auth_headers(admin) 
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['users']).not_to be_empty
      end
    end
  
    describe 'GET /api/v1/users/:id' do
      it 'returns a user when found' do
        get "/api/v1/users/#{user.id}", headers: auth_headers(admin)
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['user']['id']).to eq(user.id)
      end
  
      it 'returns not found when user does not exist' do
        get '/api/v1/users/99999', headers: auth_headers(admin)
        expect(response).to have_http_status(:not_found)
      end
    end
  
    describe 'PATCH /api/v1/users/:id' do
      it 'updates a user' do
        patch "/api/v1/users/#{user.id}",
              params: { user: { first_name: 'Updated' } }.to_json,
              headers: auth_headers(admin).merge('CONTENT_TYPE' => 'application/json')
      end
    end
  
    describe 'POST /api/v1/users' do
      it 'creates a new user' do
        post '/api/v1/users',
             params: { user: attributes_for(:user) }.to_json,
             headers: auth_headers(admin).merge('CONTENT_TYPE' => 'application/json')
      end
    end
  
  
  describe 'GET /api/v1/users/:id' do
    it 'returns a user when found' do
      get "/api/v1/users/#{user.id}", headers: auth_headers(admin)
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['user']['id']).to eq(user.id)
    end

    it 'returns not found when user does not exist' do
      get '/api/v1/users/99999', headers: auth_headers(admin)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /api/v1/users/:id' do
    it 'updates a user' do
      patch "/api/v1/users/#{user.id}",
            params: { user: { first_name: 'Updated' } }.to_json,
            headers: auth_headers(admin).merge('CONTENT_TYPE' => 'application/json')
    end
  end

  describe 'POST /api/v1/users' do
    it 'creates a new user' do
      post '/api/v1/users',
           params: { user: attributes_for(:user) }.to_json,
           headers: auth_headers(admin).merge('CONTENT_TYPE' => 'application/json')
    end
  end

end
