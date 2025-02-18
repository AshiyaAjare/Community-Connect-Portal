require 'rails_helper'

RSpec.describe User, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  context 'validation tests' do
    context 'ensures first name presence' do
      it 'true' do
        user = User.new(first_name: "Sample", last_name: "User", email: "sample.user@gmail.com", role: "contributor_user", password: "password")
        expect(user.valid?).to eq(true)
      end
      it 'false' do
        user = User.new(last_name: "user", email: "sample.user@gmail.com", role: "contributor_user", password: "password")
        expect(user.valid?).to eq(false) 
        expect(user.errors.full_messages).to eq(["First name can't be blank"])
      end
    end

    context 'ensures email presence' do
      it 'true' do
        user = User.new(first_name: "Sample", last_name: "User", email: "sample.user@gmail.com", role: "contributor_user", password: "password")
        expect(user.valid?).to eq(true)
      end
      it 'false' do
        user = User.new(first_name: "Sample", last_name: "user", role: "contributor_user", password: "password")
        expect(user.valid?).to eq(false) 
        expect(user.errors.full_messages).to eq(["Email can't be blank", "Email is invalid"])
      end
    end

  end
end
