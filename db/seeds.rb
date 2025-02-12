# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

#User.create!(first_name: "Ashiya", last_name: "Ajare", email: "admin@gmail.com", role: "admin_user", password: "password@123")


# # Clear existing data
# ResponseTag.delete_all
# QueryTag.delete_all
# Response.delete_all
# Query.delete_all
# Tag.delete_all
# User.delete_all


# db/seeds.rb

users = [
  { first_name: "Peter", last_name: "Parker", email: "peter.parker@marvel.com", role: 0 },
  { first_name: "Tony", last_name: "Stark", email: "tony.stark@marvel.com", role: 1 },
  { first_name: "Steve", last_name: "Rogers", email: "steve.rogers@marvel.com", role: 0 },
  { first_name: "Natasha", last_name: "Romanoff", email: "natasha.romanoff@marvel.com", role: 1 },
  { first_name: "Bruce", last_name: "Banner", email: "bruce.banner@marvel.com", role: 0 },
  { first_name: "Thor", last_name: "Odinson", email: "thor.odinson@marvel.com", role: 0 },
  { first_name: "Clint", last_name: "Barton", email: "clint.barton@marvel.com", role: 1 },
  { first_name: "Wanda", last_name: "Maximoff", email: "wanda.maximoff@marvel.com", role: 0 },
  { first_name: "Stephen", last_name: "Strange", email: "stephen.strange@marvel.com", role: 1 },
  { first_name: "Scott", last_name: "Lang", email: "scott.lang@marvel.com", role: 0 },
  { first_name: "T'Challa", last_name: "Black Panther", email: "tchalla@wakanda.com", role: 1 },
  { first_name: "Sam", last_name: "Wilson", email: "sam.wilson@marvel.com", role: 0 },
  { first_name: "Bucky", last_name: "Barnes", email: "bucky.barnes@marvel.com", role: 0 },
  { first_name: "Carol", last_name: "Danvers", email: "carol.danvers@marvel.com", role: 1 },
  { first_name: "Loki", last_name: "Laufeyson", email: "loki.laufeyson@marvel.com", role: 0 },
  { first_name: "Nick", last_name: "Fury", email: "nick.fury@shield.com", role: 1 },
  { first_name: "Shuri", last_name: "Wakanda", email: "shuri@wakanda.com", role: 0 },
  { first_name: "Rocket", last_name: "Raccoon", email: "rocket@guardians.com", role: 0 },
  { first_name: "Groot", last_name: "Tree", email: "groot@guardians.com", role: 0 },
  { first_name: "Drax", last_name: "Destroyer", email: "drax@guardians.com", role: 0 }
]

users.each do |user|
  User.create!(
    first_name: user[:first_name],
    last_name: user[:last_name],
    email: user[:email],
    role: user[:role],
    password: "password123",
    password_confirmation: "password123"
  )
end

puts "Seeded #{users.size} users!"


# db/seeds.rb

# Ensure users exist
users = User.all.index_by(&:email) # Index users by email for easy lookup

# Sample Queries (Assigned to Specific Users)
queries = [
  { user: users["peter.parker@marvel.com"], title: "How does the Iron Spider suit work?", content: "I want to understand the tech behind Stark's Iron Spider suit." },
  { user: users["tony.stark@marvel.com"], title: "How powerful is Vibranium?", content: "Vibranium is used in Captain America's shield and Black Panther’s suit. How strong is it compared to other metals?" },
  { user: users["steve.rogers@marvel.com"], title: "What are the side effects of the Super Soldier Serum?", content: "Besides enhanced abilities, does the serum have negative effects?" },
  { user: users["bruce.banner@marvel.com"], title: "How does gamma radiation affect the human body?", content: "Could the Hulk transformation happen in real life with gamma exposure?" },
  { user: users["wanda.maximoff@marvel.com"], title: "Can Chaos Magic alter reality?", content: "How powerful is Chaos Magic compared to other magical forces?" },
  { user: users["stephen.strange@marvel.com"], title: "How does the Time Stone manipulate time?", content: "What are the exact abilities of the Time Stone?" },
  { user: users["scott.lang@marvel.com"], title: "How does the Quantum Realm work?", content: "What are the scientific and magical properties of the Quantum Realm?" },
  { user: users["tchalla@wakanda.com"], title: "How advanced is Wakandan technology?", content: "How does Wakanda’s technology compare to Stark Industries?" },
  { user: users["rocket@guardians.com"], title: "What’s the strongest weapon in the galaxy?", content: "Which weapon is the most powerful in the Marvel universe?" },
  { user: users["nick.fury@shield.com"], title: "What is the real role of S.H.I.E.L.D.?", content: "Is S.H.I.E.L.D. just intelligence, or do they have other objectives?" }
]

queries.each do |q|
  Query.create!(user_id: q[:user].id, title: q[:title], content: q[:content], flagged: false, status: false)
end

puts "Seeded #{queries.size} queries!"

# Sample Responses (Assigned Logically)
responses = [
  { user: users["tony.stark@marvel.com"], query_title: "How does the Iron Spider suit work?", content: "The Iron Spider suit is made from nanotechnology and integrates AI." },
  { user: users["shuri@wakanda.com"], query_title: "How powerful is Vibranium?", content: "Vibranium absorbs kinetic energy, making it nearly indestructible." },
  { user: users["bucky.barnes@marvel.com"], query_title: "What are the side effects of the Super Soldier Serum?", content: "It enhances strength but can also amplify aggression in unstable individuals." },
  { user: users["bruce.banner@marvel.com"], query_title: "How does gamma radiation affect the human body?", content: "In reality, gamma radiation would be lethal, but in the MCU, it triggers mutation." },
  { user: users["stephen.strange@marvel.com"], query_title: "Can Chaos Magic alter reality?", content: "Yes, Chaos Magic can reshape reality, as shown in Wanda’s abilities." },
  { user: users["thor.odinson@marvel.com"], query_title: "What’s the strongest weapon in the galaxy?", content: "Stormbreaker is one of the most powerful weapons, capable of killing Thanos." },
  { user: users["tchalla@wakanda.com"], query_title: "How advanced is Wakandan technology?", content: "Wakandan tech surpasses Stark Industries due to Vibranium-based advancements." },
  { user: users["scott.lang@marvel.com"], query_title: "How does the Quantum Realm work?", content: "The Quantum Realm exists outside normal space-time, enabling time travel." },
  { user: users["nick.fury@shield.com"], query_title: "What is the real role of S.H.I.E.L.D.?", content: "S.H.I.E.L.D. was created for counterintelligence and threat prevention." },
  { user: users["clint.barton@marvel.com"], query_title: "How powerful is Vibranium?", content: "Vibranium is powerful, but it has weaknesses—like energy overload." },
  { user: users["carol.danvers@marvel.com"], query_title: "What’s the strongest weapon in the galaxy?", content: "The Tesseract contains immense cosmic energy, making it incredibly powerful." },
  { user: users["wanda.maximoff@marvel.com"], query_title: "Can Chaos Magic alter reality?", content: "Yes, Wanda's Hex is proof that Chaos Magic can rewrite existence." },
  { user: users["drax@guardians.com"], query_title: "What’s the strongest weapon in the galaxy?", content: "The Infinity Gauntlet wielded all six stones, making it unstoppable." },
  { user: users["rocket@guardians.com"], query_title: "How does the Quantum Realm work?", content: "Pym Particles allow us to enter and navigate the Quantum Realm safely." }
]

responses.each do |r|
  query = Query.find_by(title: r[:query_title])
  Response.create!(user_id: r[:user].id, query_id: query.id, content: r[:content], upvotes: 0, downvotes: 0, likes: 0, approval: false, flagged: false)
end

puts "Seeded #{responses.size} responses!"

# Sample Tags (Assigned Meaningfully)
tags = ["Technology", "Science", "Magic", "Weapons", "Cosmic", "Multiverse", "Time Travel", "Mutants", "Shield", "Vibranium"]
tag_objects = tags.map { |name| Tag.create!(name: name) }

puts "Seeded #{tag_objects.size} tags!"

# Assign Tags to Queries
query_tags = {
  "How does the Iron Spider suit work?" => ["Technology"],
  "How powerful is Vibranium?" => ["Science", "Vibranium"],
  "What are the side effects of the Super Soldier Serum?" => ["Science", "Mutants"],
  "How does gamma radiation affect the human body?" => ["Science"],
  "Can Chaos Magic alter reality?" => ["Magic", "Multiverse"],
  "How does the Time Stone manipulate time?" => ["Magic", "Time Travel"],
  "How does the Quantum Realm work?" => ["Science", "Multiverse", "Time Travel"],
  "How advanced is Wakandan technology?" => ["Technology", "Vibranium"],
  "What’s the strongest weapon in the galaxy?" => ["Weapons", "Cosmic"],
  "What is the real role of S.H.I.E.L.D.?" => ["Shield"]
}

query_tags.each do |query_title, tag_names|
  query = Query.find_by(title: query_title)
  tag_names.each do |tag_name|
    tag = Tag.find_by(name: tag_name)
    QueryTag.create!(query_id: query.id, tag_id: tag.id)
  end
end

puts "Seeded query-tag relationships!"

# Assign Tags to Responses
responses.each do |r|
  response = Response.find_by(content: r[:content])
  tag = Tag.find_by(name: query_tags[r[:query_title]].first)
  ResponseTag.create!(response_id: response.id, tag_id: tag.id) if tag
end

puts "Seeded response-tag relationships!"
