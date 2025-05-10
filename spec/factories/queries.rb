FactoryBot.define do
  factory :query do
    title { Faker::Lorem.sentence(word_count: 5) }
    content { Faker::Lorem.paragraph(sentence_count: 5) }
    # user 
    status { false }
    flagged { false }
    association :user

    after(:create) do |query|
      query.tags << create(:tag)
    end

    trait :discarded do
      discarded_at { Time.current }
    end
  end
end

  