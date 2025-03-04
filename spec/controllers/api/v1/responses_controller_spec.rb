require 'rails_helper'

RSpec.describe Api::V1::ResponsesController, type: :controller do
  let!(:user) { create(:user) }
  let!(:admin) { create(:user, role: :admin_user) }
  let!(:query) { create(:query) }
  let!(:response_record) { create(:response, query: query, user: user) }

  before do
    headers = auth_headers(admin)
    
    request.headers.merge!(headers)
  end
  

  describe "GET /api/v1/responses" do
    it "returns a list of responses" do
      get :index, format: :json
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['responses']).not_to be_empty
    end
  end

  describe "GET /api/v1/responses/:id" do
    # it "returns a specific response" do
    #   get :show, params: { id: response_record.id }, format: :json
    #   expect(response).to have_http_status(:success)
    #   json_response = JSON.parse(response.body)
    #   expect(json_response['response']['id']).to eq(response_record.id)
    # end

    it "returns not found for a non-existent response" do
      get :show, params: { id: 9999 }, format: :json
      expect(response).to have_http_status(:not_found)
    end
  end
  #WORKING  ^

  # describe "POST /api/v1/queries/:query_id/responses" do
  #   let(:valid_params) { { response: { content: "New response" }, query_id: query.id } }

  #   it "creates a response" do
  #     expect {
  #       post :create, params: valid_params, format: :json
  #     }.to change(Response, :count).by(1)
  #     expect(response).to have_http_status(:created)
  #   end

  #   it "returns an error when params are invalid" do
  #     post :create, params: { response: { content: "" }, query_id: query.id }, format: :json
  #     expect(response).to have_http_status(:unprocessable_entity)
  #   end
  # end


  describe "PUT /api/v1/responses/:id" do
    let(:update_params) { { id: response_record.id, response: { content: "Updated response" } } }

    it "updates a response" do
      put :update, params: update_params, format: :json
      expect(response).to have_http_status(:success)
      expect(response_record.reload.content).to eq("Updated response")
    end
  end

  describe "PATCH /api/v1/responses/:id/upvote" do
    it "increments upvotes" do
      expect {
        patch :upvote, params: { id: response_record.id }, format: :json
      }.to change { response_record.reload.upvotes }.by(1)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /api/v1/responses/:id/downvote" do
    it "increments downvotes" do
      expect {
        patch :downvote, params: { id: response_record.id }, format: :json
      }.to change { response_record.reload.downvotes }.by(1)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /api/v1/responses/:id/like" do
    it "increments likes" do
      expect {
        patch :like, params: { id: response_record.id }, format: :json
      }.to change { response_record.reload.likes }.by(1)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /api/v1/responses/:id/toggle_approval" do
    before { request.headers.merge!(auth_headers(admin)) }

    it "toggles approval status" do
      expect {
        patch :toggle_approval, params: { id: response_record.id }, format: :json
      }.to change { response_record.reload.approval }.to(true)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /api/v1/responses/:id/toggle_flag" do
    it "toggles flagged status" do
      expect {
        patch :toggle_flag, params: { id: response_record.id }, format: :json
      }.to change { response_record.reload.flagged }.to(true)
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /api/v1/responses/:id" do
    it "soft deletes a response" do
      expect {
        delete :destroy, params: { id: response_record.id }, format: :json
      }.to change { response_record.reload.discarded? }.to(true)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/v1/responses/:id/restore" do
    before { response_record.discard }

    it "restores a soft deleted response" do
      expect {
        patch :restore, params: { id: response_record.id }, format: :json
      }.to change { response_record.reload.discarded? }.to(false)
      expect(response).to have_http_status(:success)
    end
  end

end
