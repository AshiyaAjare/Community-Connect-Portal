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
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe 'associations' do
    it { should have_many(:queries).dependent(:destroy) }
    it { should have_many(:responses).dependent(:destroy) }
    it { should have_one_attached(:profile_image) }
  end

  describe 'enum role' do
    it { should define_enum_for(:role).with_values(contributor_user: 0, moderator_user: 1, admin_user: 2) }
  end

  describe 'default role assignment' do
    it 'sets default role to contributor_user when inviting a user' do
      user = User.new
      user.send(:set_default_role)
      expect(user.role).to eq('contributor_user')
    end
  end

  describe '#display_profile_image_url' do
    let(:user) { create(:user) }

    context 'when profile image is attached' do
      it 'returns the profile image URL' do
        user.profile_image.attach(io: File.open(Rails.root.join('spec/fixtures/test_image.png')), filename: 'test_image.png', content_type: 'image/png')
        expect(user.display_profile_image_url).to include('/rails/active_storage/')
      end
    end

    context 'when profile image is not attached' do
      it 'returns the default gravatar URL' do
        expect(user.display_profile_image_url).to eq('https://www.gravatar.com/avatar/3b3be63a4c2a439b013787725dfce802?d=identicon')
      end
    end
  end
end
