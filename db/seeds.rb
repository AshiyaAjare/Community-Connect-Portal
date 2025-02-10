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

# # Create users (without admin role)
users = [
  { first_name: "Alice", last_name: "Smith", email: "alice@example.com", password: "password", role: 0 },
  { first_name: "Bob", last_name: "Johnson", email: "bob@example.com", password: "password", role: 1 },
  { first_name: "Charlie", last_name: "Brown", email: "charlie@example.com", password: "password", role: 0 },
  { first_name: "David", last_name: "Miller", email: "david@example.com", password: "password", role: 1 }
]

users.each { |user| User.create!(user) }

puts "✅ Created #{User.count} users."

# Fetch users
contributor = User.where(role: 0)
moderator = User.where(role: 1)

# Create queries
queries = [
  { user: contributor.sample, title: "How to install Rails?", content: "Can someone help me install Rails?" },
  { user: moderator.sample, title: "Best practices for REST APIs?", content: "What are the best practices to follow when designing a REST API?" },
  { user: contributor.sample, title: "Understanding ActiveRecord?", content: "How does ActiveRecord handle associations?" }
]

queries.each { |query| Query.create!(query) }

puts "✅ Created #{Query.count} queries."

# Fetch queries
query_records = Query.all

# Create responses
responses = [
  { user: moderator.sample, query: query_records.sample, content: "You can install Rails using `gem install rails`.", upvotes: 3, downvotes: 0, likes: 5, approval: true, flagged: false },
  { user: contributor.sample, query: query_records.sample, content: "Make sure to follow REST principles like proper status codes and resource naming.", upvotes: 2, downvotes: 1, likes: 4, approval: false, flagged: false },
  { user: contributor.sample, query: query_records.sample, content: "ActiveRecord handles associations using `belongs_to`, `has_many`, etc.", upvotes: 5, downvotes: 0, likes: 7, approval: true, flagged: false }
]

responses.each { |response| Response.create!(response) }

puts "✅ Created #{Response.count} responses."

# Create tags
tags = ["Ruby", "Rails", "API", "ActiveRecord", "Database", "Backend"]
tags.each { |tag| Tag.create!(name: tag) }

puts "✅ Created #{Tag.count} tags."

# Associate queries with tags
Query.all.each do |query|
  query.tags << Tag.order("RANDOM()").limit(2)
end

# Associate responses with tags
Response.all.each do |response|
  response.tags << Tag.order("RANDOM()").limit(1)
end

puts "✅ Associated queries and responses with tags."

