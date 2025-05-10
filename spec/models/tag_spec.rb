require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'associations' do
    it { should have_many(:query_tags).dependent(:destroy) }
    it { should have_many(:queries).through(:query_tags) }
    it { should have_many(:response_tags).dependent(:destroy) }
    it { should have_many(:responses).through(:response_tags) }
  end

  describe 'validations' do
    subject { create(:tag) } # Ensures uniqueness validation is tested properly

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'soft delete (discard)' do
    let!(:tag) { create(:tag) }

    it 'is not discarded by default' do
      expect(tag.discarded?).to be_falsey
    end

    it 'can be discarded' do
      tag.discard
      expect(tag.discarded?).to be_truthy
    end

    it 'can be restored' do
      tag.discard
      tag.undiscard
      expect(tag.discarded?).to be_falsey
    end
  end
end
