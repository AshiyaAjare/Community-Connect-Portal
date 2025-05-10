FactoryBot.define do
    factory :moderation_log do
      association :query, factory: :query
      association :response, factory: :response
      action { ModerationLog.actions.keys.sample } 
    end
  end
  