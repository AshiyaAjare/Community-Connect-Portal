FactoryBot.define do
    factory :query do
      title { Faker::Lorem.sentence(word_count: 5) }
      content { Faker::Lorem.paragraph(sentence_count: 5) }
      user  # Associates the query with a user
  
      trait :discarded do
        discarded_at { Time.current }
      end
    end
  end
  