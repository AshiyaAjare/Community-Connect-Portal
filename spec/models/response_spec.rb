require 'rails_helper'

RSpec.describe Response, type: :model do
  let(:user) { create(:user) }
  let(:query) { create(:query, status: false) } # Initially open query
  let(:response) { create(:response, user: user, query: query, content: "Sample response") }

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:query) }
    it { should have_many(:response_tags).dependent(:destroy) }
    it { should have_many(:tags).through(:response_tags) }
  end

  describe "validations" do
    it { should validate_presence_of(:content) }
  end

  describe "#close_query_if_approved" do
    it "closes the query when response is approved" do
      expect(query.status).to be false # Query should be open initially
      
      response.update!(approval: true) # Approve the response

      expect(query.reload.status).to be true # Query should be closed
    end
  end
end
