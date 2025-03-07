require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:admin_user) { create(:user, role: :admin_user) }
  let!(:user) { create(:user) }

  before do
    sign_in admin_user # Assuming Devise is used
  end

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    context "when the user exists" do
      it "returns a successful response" do
        get :show, params: { id: user.id }
        expect(response).to have_http_status(:success)
      end
    end

    context "when the user does not exist" do
      it "redirects to the users path with an alert" do
        get :show, params: { id: 9999 } # Non-existent ID
        expect(response).to redirect_to(users_path)
        expect(flash[:alert]).to eq("User not found")
      end
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new user and redirects" do
        user_params = attributes_for(:user)
        expect {
          post :create, params: { user: user_params }
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(users_path)
        expect(flash[:notice]).to eq("User created")
      end
    end

    context "with invalid attributes" do
      it "does not create a new user and renders new" do
        user_params = attributes_for(:user, email: "")
        expect {
          post :create, params: { user: user_params }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    it "updates the user and redirects" do
      patch :update, params: { id: user.id, user: { first_name: "Updated Name" } }
      user.reload
      expect(user.first_name).to eq("Updated Name")
      expect(response).to redirect_to(users_path)
    end
  end

  describe "DELETE #destroy" do
    it "soft deletes the user and redirects" do
      delete :destroy, params: { id: user.id }
      expect(user.reload.discarded?).to be_truthy
      expect(response).to redirect_to(users_path)
    end
  end
end
