require 'rails_helper'

RSpec.describe Api::V1::QueriesController, type: :controller do
  let!(:user) { create(:user) }
  let!(:admin) { create(:user, role: :admin_user) }
  let!(:query) { create(:query, user: user) }
  let!(:tag) { create(:tag) }

  before do
    request.headers['Accept'] = 'application/json'
    request.headers.merge!(auth_headers(user))
  end

  describe "GET /api/v1/queries" do
    it "returns a list of queries" do
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['queries'].length).to eq(Query.kept.count)
    end

    it "filters queries by tag name" do
      tagged_query = create(:query)
      search_tag = create(:tag, name: 'specific_tag')
      tagged_query.tags << search_tag
      
      get :index, params: { search: 'specific_tag' }, format: :json
      
      json_response = JSON.parse(response.body)
      expect(json_response['queries'].length).to eq(1)
      expect(json_response['queries'][0]['id']).to eq(tagged_query.id)
    end
  end

  describe "GET /api/v1/queries/:id" do
    it "returns a specific query" do
      get :show, params: { id: query.id }, format: :json
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['query']['id']).to eq(query.id)
    end

    it "returns not found for a non-existent query" do
      get :show, params: { id: 9999 }, format: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/queries" do
    let(:valid_attributes) do
      { title: 'Test Query', content: 'This is a test query content', user_id: user.id }
    end

    it "creates a new query" do
      expect {
        post :create, params: valid_attributes, format: :json
      }.to change(Query, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "creates a query with existing tags" do
      expect {
        post :create, params: valid_attributes.merge(tag_ids: [tag.id]), format: :json
      }.to change(Query, :count).by(1)
      
      json_response = JSON.parse(response.body)
      created_query = Query.find(json_response['query']['id'])
      expect(created_query.tags).to include(tag)
    end

    it "creates a query with a new tag" do
      post :create, params: valid_attributes.merge(new_tag: 'brand_new_tag'), format: :json
      
      json_response = JSON.parse(response.body)
      created_query = Query.find(json_response['query']['id'])
      expect(created_query.tags.map(&:name)).to include('brand_new_tag')
    end
  end

  describe "PUT /api/v1/queries/:id" do
    # it "updates a query" do
    #   patch :update, params: { id: query.id, query: { title: 'Updated Title' } }, format: :json
    #   expect(response).to have_http_status(:ok)
    #   query.reload
    #   expect(query.title).to eq('Updated Title')
    # end

    it "updates tags for the query" do
      new_tag = create(:tag)
      
      patch :update, params: { id: query.id, query: { tag_ids: [new_tag.id] } }, format: :json
      
      expect(response).to have_http_status(:ok)
      expect(query.reload.tags).to include(new_tag)
    end
  end

  describe "PATCH /api/v1/queries/:id/update_status" do
    before { request.headers.merge!(auth_headers(admin)) }

    it "toggles query status" do
      allow_any_instance_of(User).to receive(:admin_user?).and_return(true)
      
      expect {
        patch :update_status, params: { id: query.id }, format: :json
      }.to change { query.reload.status }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /api/v1/queries/:id/update_flag" do
    before { request.headers.merge!(auth_headers(admin)) }

    it "toggles query flag status" do
      allow_any_instance_of(User).to receive(:admin_user?).and_return(true)
      allow(ModerationLog).to receive(:find_or_initialize_by).and_return(
        instance_double(ModerationLog, update: true)
      )
      
      expect {
        patch :update_flag, params: { id: query.id }, format: :json
      }.to change { query.reload.flagged }
      expect(response).to have_http_status(:ok)
    end
  end

  

  # describe "PATCH /api/v1/queries/:id/restore", if: Rails.application.routes.recognize_path('/api/v1/queries/1/restore', method: :patch) rescue false do
  #   before { query.discard }
  
  #   it "restores a soft deleted query" do
  #     expect {
  #       patch :restore, params: { id: query.id }, format: :json
  #     }.to change { query.reload.discarded? }.to(false)
  #     expect(response).to have_http_status(:ok)
  #   end
  # end
end