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


# Sample users
# user1 = User.create!(
#   first_name: "John", 
#   last_name: "Doe", 
#   email: "john.doe2@example.com", 
#   password: "password", 
#   role: :moderator_user
# )

# user2 = User.create!(
#   first_name: "Jane", 
#   last_name: "Smith", 
#   email: "jane.smith2@example.com", 
#   password: "password", 
#   role: :contributor_user
# )
user1 = User.create!(first_name: "Alice", last_name: "Doe", email: "alice2@example.com", password: "password", role: "contributor_user")
user2 = User.create!(first_name: "Bob", last_name: "Smith", email: "bob2@example.com", password: "password", role: "moderator_user")
# Sample queries
query1 = Query.create!(
  title: "How to integrate Turbo Streams in Rails?", 
  content: "I'm looking for a way to use Turbo Streams in my Rails app to dynamically update parts of the page.",
  user: user1, 
  flagged: false, 
  status: true
)

query2 = Query.create!(
  title: "Best practices for database indexing in Rails", 
  content: "Can anyone suggest the best indexing strategies to improve performance in a large-scale Rails app?",
  user: user2, 
  flagged: false, 
  status: true
)

query3 = Query.create!(
  title: "Troubleshooting ActiveRecord associations", 
  content: "I'm facing an issue with my ActiveRecord associations, and I need some guidance.",
  user: user1, 
  flagged: false, 
  status: false
)

# Sample tags
tag1 = Tag.create!(name: "Turbo")
tag2 = Tag.create!(name: "Rails-Ruby")
tag3 = Tag.create!(name: "Database Schema")
tag4 = Tag.create!(name: "ActiveRecord & Storage")

# Assigning tags to queries
query1.tags << tag1
query1.tags << tag2
query2.tags << tag2
query2.tags << tag3
query3.tags << tag4




# Create Responses (Each response inherits the tags of its associated query)
response1 = Response.create!(
  user: user2, 
  query: query1, 
  content: "You can use Devise and JWT for authentication.",
  upvotes: 5,
  downvotes: 0,
  likes: 3,
  approval: true
)
response1.tags << query1.tags  # Inherit tags from the query

response2 = Response.create!(
  user: user1, 
  query: query2, 
  content: "Use Bullet gem to detect N+1 queries and eager load associations.",
  upvotes: 10,
  downvotes: 1,
  likes: 7,
  approval: true
)
response2.tags << query2.tags  # Inherit tags from the query

# Create a response with additional selected tags
response3 = Response.create!(
  user: user2, 
  query: query1, 
  content: "You can also use Omniauth for social authentication.",
  upvotes: 3,
  downvotes: 0,
  likes: 2,
  approval: false
)
response3.tags << query1.tags  # Inherit tags from the query
response3.tags << tag3  # Additional tag selected manually

