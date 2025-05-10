require 'rails_helper'

RSpec.describe ResponsesController, type: :controller do
  let(:admin_user) { create(:user, role: :admin_user) }
  let(:regular_user) { create(:user, role: :contributor) }
  let(:query) { create(:query, user: regular_user) }
  let!(:response_record) { create(:response, query: query, user: regular_user) }

  before do
    sign_in admin_user # Simulating an admin user login
  end

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(@controller.response).to have_http_status(:ok) # Fix: Use @controller.response
    end
  end

  describe "PATCH #upvote" do
    it "increments the response upvotes" do
      expect {
        patch :upvote, params: { id: response_record.id }
      }.to change { response_record.reload.upvotes }.by(1)

      expect(@controller.response).to have_http_status(:found) # Fix: Use @controller.response
    end
  end

  describe "PATCH #downvote" do
    it "increments the response downvotes" do
      expect {
        patch :downvote, params: { id: response_record.id }
      }.to change { response_record.reload.downvotes }.by(1)

      expect(@controller.response).to have_http_status(:found)
    end
  end

  describe "PATCH #like" do
    it "increments the response likes" do
      expect {
        patch :like, params: { id: response_record.id }
      }.to change { response_record.reload.likes }.by(1)

      expect(@controller.response).to have_http_status(:found)
    end
  end

  describe "PATCH #toggle_approval" do
    it "toggles approval status" do
      initial_approval = response_record.approval
      patch :toggle_approval, params: { id: response_record.id }
      expect(response_record.reload.approval).to eq(!initial_approval)

      expect(@controller.response).to have_http_status(:found)
    end
  end

  describe "PATCH #toggle_flag" do
    it "toggles flag status" do
      initial_flag = response_record.flagged
      patch :toggle_flag, params: { id: response_record.id }
      expect(response_record.reload.flagged).to eq(!initial_flag)

      expect(@controller.response).to have_http_status(:found)
    end
  end

  describe "DELETE #destroy" do
    it "soft deletes the response" do
      expect {
        delete :destroy, params: { id: response_record.id }
      }.to change { response_record.reload.discarded? }.from(false).to(true)

      expect(@controller.response).to have_http_status(:found)
    end
  end
end
