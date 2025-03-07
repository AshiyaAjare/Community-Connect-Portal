require 'rails_helper'

RSpec.describe QueriesController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user, role: :admin_user) }
  let(:query) { create(:query) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "assigns @queries with all kept queries when no search param is present" do
      query1 = create(:query)
      query2 = create(:query)
      get :index
      expect(assigns(:queries)).to match_array([query1, query2])
    end

    it "filters queries based on search param" do
      tag1 = create(:tag, name: "Ruby")
      tag2 = create(:tag, name: "Rails")
      query1 = create(:query, tags: [tag1])
      query2 = create(:query, tags: [tag2])

      get :index, params: { search: "Ruby" }
      expect(assigns(:queries)).to include(query1)
      expect(assigns(:queries)).not_to include(query2)
    end
  end

  describe "GET #show" do
    it "returns a successful response" do
      get :show, params: { id: query.id }
      expect(response).to have_http_status(:success)
    end

    it "assigns @query and @responses_count" do
      response1 = create(:response, query: query)
      response2 = create(:response, query: query)

      get :show, params: { id: query.id }
      expect(assigns(:query)).to eq(query)
      expect(assigns(:responses_count)).to eq(2)
    end
  end

  describe "PATCH #update_status" do
    it "toggles the query status" do
      expect {
        patch :update_status, params: { id: query.id }
        query.reload
      }.to change { query.status }.to(!query.status)
    end

    it "redirects to queries path" do
      patch :update_status, params: { id: query.id }
      expect(response).to redirect_to(queries_path)
      expect(flash[:notice]).to eq("Query status updated.")
    end
  end

  describe "PATCH #update_flag" do
    context "when user is an admin" do
      before { sign_in admin }

      it "toggles the flagged status" do
        expect {
          patch :update_flag, params: { id: query.id }
          query.reload
        }.to change { query.flagged }.to(!query.flagged)
      end

      it "creates or updates a moderation log" do
        expect {
          patch :update_flag, params: { id: query.id }
        }.to change { ModerationLog.where(query_id: query.id, action: :flag).count }.by(1)
      end

      it "renders turbo_stream response" do
        patch :update_flag, params: { id: query.id }, format: :turbo_stream
        expect(response.content_type).to include("text/vnd.turbo-stream.html")
      end
    end

    context "when user is not an admin" do
      it "does not update the flagged status" do
        expect {
          patch :update_flag, params: { id: query.id }
          query.reload
        }.not_to change { query.flagged }
      end

      it "sets an unauthorized alert message" do
        patch :update_flag, params: { id: query.id }
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end

  describe "DELETE #destroy" do
    it "soft deletes the query" do
      expect {
        delete :destroy, params: { id: query.id }
        query.reload
      }.to change { query.discarded? }.from(false).to(true)
    end

    it "creates a moderation log entry" do
      expect {
        delete :destroy, params: { id: query.id }
      }.to change { ModerationLog.where(query_id: query.id, action: :soft_delete).count }.by(1)
    end

    it "redirects to queries path with a notice" do
      delete :destroy, params: { id: query.id }
      expect(response).to redirect_to(queries_path)
      expect(flash[:notice]).to eq("Query deleted.")
    end
  end

  describe "PATCH #restore" do
    before do
      query.discard
    end

    it "restores a soft-deleted query" do
      expect {
        patch :restore, params: { id: query.id }
        query.reload
      }.to change { query.discarded? }.from(true).to(false)
    end

    it "redirects to moderation logs path with a notice" do
      patch :restore, params: { id: query.id }
      expect(response).to redirect_to(moderation_logs_path)
      expect(flash[:notice]).to eq("Query restored successfully.")
    end
  end
end
