require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:admin) { create(:user, role: :admin_user) }
  let(:user) { create(:user) }

  before { sign_in(admin) }

  describe 'GET #index' do
    it 'returns a list of users' do
      get :index
      expect(response).to be_successful
      expect(assigns(:users)).to include(user)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested user' do
      get :show, params: { id: user.id }
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'POST #create' do
    it 'creates a new user' do
      expect {
        post :create, params: { user: attributes_for(:user) }
      }.to change(User, :count).by(1)
      expect(response).to redirect_to(users_path)
    end
  end

  describe 'PATCH #update' do
    it 'updates the user' do
      patch :update, params: { id: user.id, user: { first_name: 'Updated' } }
      expect(user.reload.first_name).to eq('Updated')
    end
  end

  describe 'DELETE #destroy' do
    it 'soft deletes the user' do
      delete :destroy, params: { id: user.id }
      expect(user.reload.discarded?).to be_truthy
    end
  end
end
