require 'rails_helper'

RSpec.describe TagsController, type: :controller do
  let(:user) { create(:user, :admin_user) } # Ensure admin user is created
  let(:tag) { create(:tag, name: "SampleTag") }
  let(:valid_attributes) { { name: "New Tag" } }
  let(:invalid_attributes) { { name: "" } }

  before do
    sign_in user # Devise helper to authenticate
  end

  describe "GET #index" do
    it "assigns all kept tags as @tags" do
      tag # Ensures tag exists before request
      get :index
      expect(assigns(:tags)).to include(tag)
    end
  end

  # describe "GET #show" do
  #   it "assigns the requested tag as @tag" do
  #     get :show, params: { id: tag.id }
  #     expect(assigns(:tag)).to eq(tag)
  #   end
  # end

  # describe "GET #new" do
  #   it "assigns a new tag as @tag" do
  #     get :new
  #     expect(assigns(:tag)).to be_a_new(Tag)
  #   end
  # end

  # describe "POST #create" do
  #   context "with valid attributes" do
  #     it "creates a new Tag" do
  #       expect {
  #         post :create, params: { tag: valid_attributes }
  #       }.to change(Tag, :count).by(1)
  #     end

  #     it "redirects to the tags index page with a success message" do
  #       post :create, params: { tag: valid_attributes }
  #       expect(response).to redirect_to(tags_path)
  #       expect(flash[:notice]).to eq("Tag created successfully")
  #     end
  #   end

  #   context "with invalid attributes" do
  #     it "does not create a new tag and renders the new template" do
  #       expect {
  #         post :create, params: { tag: invalid_attributes }
  #       }.not_to change(Tag, :count)
  #       expect(response).to render_template(:new)
  #       expect(flash[:alert]).to include("Error creating tag")
  #     end
  #   end
  # end

  # describe "PATCH #update" do
  #   context "with valid attributes" do
  #     it "updates the requested tag" do
  #       patch :update, params: { id: tag.id, tag: { name: "Updated Tag" } }
  #       tag.reload
  #       expect(tag.name).to eq("Updated Tag")
  #     end

  #     it "redirects to the tags index page with a success message" do
  #       patch :update, params: { id: tag.id, tag: { name: "Updated Tag" } }
  #       expect(response).to redirect_to(tags_path)
  #       expect(flash[:notice]).to eq("Tag updated successfully.")
  #     end
  #   end

  #   context "with invalid attributes" do
  #     it "does not update the tag and renders the edit template" do
  #       patch :update, params: { id: tag.id, tag: { name: "" } }
  #       expect(tag.reload.name).not_to eq("")
  #       expect(response).to render_template(:edit)
  #     end
  #   end
  # end

  describe "DELETE #destroy" do
    it "soft deletes the tag and redirects to tags index" do
      delete :destroy, params: { id: tag.id }
      tag.reload
      expect(tag.discarded?).to be true
      expect(response).to redirect_to(tags_path)
      expect(flash[:notice]).to eq("Tag was successfully discarded.")
    end
  end
end
