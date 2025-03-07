require 'rails_helper'

RSpec.describe Api::V1::AuthenticationController, type: :controller do
  include AuthHelper

  let!(:admin_user) { create(:user, password: 'password123', role: :admin_user) }
  let!(:invited_user) { create(:user, password: 'password123', invitation_sent_at: Time.current) }
  let!(:non_invited_user) { create(:user, password: 'password123') }
  let!(:invalid_user) { { email: 'wrong@example.com', password: 'wrongpassword' } }

  describe 'POST #login' do
    context 'when credentials are valid' do
      it 'returns a JWT token for an admin user' do
        post :login, params: { email: admin_user.email, password: 'password123' }, format: :json
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to have_key('token')
        expect(body['user']['email']).to eq(admin_user.email)
      end

      it 'returns a JWT token for an invited user' do
        post :login, params: { email: invited_user.email, password: 'password123' }, format: :json
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to have_key('token')
        expect(body['user']['email']).to eq(invited_user.email)
      end
    end

    context 'when user is not invited' do
      it 'returns an unauthorized error' do
        post :login, params: { email: non_invited_user.email, password: 'password123' }, format: :json
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['error']).to eq('Invitation not sent. Contact the admin.')
      end
    end

    context 'when credentials are invalid' do
      it 'returns an unauthorized error for incorrect password' do
        post :login, params: { email: admin_user.email, password: 'wrongpassword' }, format: :json
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['error']).to eq('Invalid email or password')
      end

      it 'returns an unauthorized error for non-existent user' do
        post :login, params: invalid_user, format: :json
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['error']).to eq('Invalid email or password')
      end
    end

    context 'when request has missing parameters' do
      it 'returns an error if email is missing' do
        post :login, params: { password: 'password123' }, format: :json
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['error']).to eq('Invalid email or password')
      end

      it 'returns an error if password is missing' do
        post :login, params: { email: admin_user.email }, format: :json
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['error']).to eq('Invalid email or password')
      end
    end

    context 'when request has empty values' do
      it 'returns an error if email is empty' do
        post :login, params: { email: '', password: 'password123' }, format: :json
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['error']).to eq('Invalid email or password')
      end

      it 'returns an error if password is empty' do
        post :login, params: { email: admin_user.email, password: '' }, format: :json
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['error']).to eq('Invalid email or password')
      end
    end

    context 'when request has nil values' do
      it 'returns an error if email is nil' do
        post :login, params: { email: nil, password: 'password123' }, format: :json
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['error']).to eq('Invalid email or password')
      end

      it 'returns an error if password is nil' do
        post :login, params: { email: admin_user.email, password: nil }, format: :json
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['error']).to eq('Invalid email or password')
      end
    end

    
  end
end
