require 'rails_helper'

RSpec.describe Query, type: :model do
  let(:user) { create(:user) }
  let(:query) { build(:query, user: user) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:responses).dependent(:destroy) }
    it { should have_many(:query_tags).dependent(:destroy) }
    it { should have_many(:tags).through(:query_tags) }
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_least(10).is_at_most(1000) }
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }
  end

  describe 'soft delete (discard)' do
    it 'discards a query instead of deleting it' do
      query.save!
      query.discard
      expect(query.discarded?).to be true
      expect(Query.kept).not_to include(query)
    end
  end
end
