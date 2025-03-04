FactoryBot.define do
    factory :response do
      content { "This is a test response." }
      association :user
      association :query
  
      trait :approved do
        approval { true }
      end
  
      trait :flagged do
        flagged { true }
      end
    end
  end
  