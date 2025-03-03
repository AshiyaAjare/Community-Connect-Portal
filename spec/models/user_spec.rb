require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_length_of(:first_name).is_at_most(50) }
    it { should validate_presence_of(:last_name) }
    it { should validate_length_of(:last_name).is_at_most(50) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }
    it { should validate_presence_of(:password).on(:create) }
    it { should validate_length_of(:password).is_at_least(6).on(:create) }
  end

  describe 'associations' do
    it { should have_many(:queries) }
    it { should have_many(:queries).dependent(:destroy) }
    it { should have_many(:responses) }
    it { should have_many(:responses).dependent(:destroy) }
    it { should have_one_attached(:profile_image) }
  end

  describe '#display_profile_image_url' do
    let(:user) { create(:user) }

    it 'returns the profile image URL if attached' do
      user.profile_image.attach(io: File.open(Rails.root.join('spec/fixtures/profile.png')), filename: 'profile.png', content_type: 'image/png')
      expect(user.display_profile_image_url).to include('rails/active_storage')
    end

    it 'returns the default Gravatar URL if no image is attached' do
      expect(user.display_profile_image_url).to eq('https://www.gravatar.com/avatar/3b3be63a4c2a439b013787725dfce802?d=identicon')
    end
  end

  describe 'role management' do
    it 'assigns default role to contributor_user before invitation is created' do
      user = User.new(email: 'test@example.com', first_name: 'Test', last_name: 'User')
      user.send(:set_default_role) # calling private method directly
      expect(user.role).to eq('contributor_user')
    end
  end
end
