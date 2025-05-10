require 'rails_helper'

RSpec.describe ModerationLog, type: :model do
  describe "associations" do
    it { should belong_to(:query).optional }
    it { should belong_to(:response).optional }
  end

  describe "enums" do
    it "defines the correct actions" do
      expect(ModerationLog.actions).to eq({
        "no_action" => 0,
        "soft_delete" => 1,
        "approve" => 2,
        "flag" => 3,
        "restore" => 4
      })
    end

    it "allows setting action correctly" do
      log = create(:moderation_log, action: "approve")
      expect(log.approve?).to be true
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      moderation_log = build(:moderation_log)
      expect(moderation_log).to be_valid
    end

    it "is valid without a query or response" do
      moderation_log = build(:moderation_log, query: nil, response: nil)
      expect(moderation_log).to be_valid
    end

    it "is valid with only a query" do
      moderation_log = build(:moderation_log, response: nil)
      expect(moderation_log).to be_valid
    end

    it "is valid with only a response" do
      moderation_log = build(:moderation_log, query: nil)
      expect(moderation_log).to be_valid
    end
  end
end
