namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_users
    make_textposts
    make_relationships
    make_comments
    make_messages
    make_likes
  end
end

def make_users
  @cities = ["Manchester", "Sheffield", "Leeds", "London",
              "Liverpool", "Birmingham", "Nottingham"]

  User.create!(first_name: "Example",
               last_name: "User",
               username: "useple",
               email: "user@example.com",
               password: "foobar",
               password_confirmation: "foobar")

  User.create!(first_name: "Example2",
               last_name: "User2",
               username: "useple2",
               email: "user2@example.com",
               password: "foobar2",
               password_confirmation: "foobar2")
    
  99.times do |n|
    first_name  = Faker::Name.first_name
    last_name  = Faker::Name.last_name
    username  = "breaker#{n}_" + Faker::Name.first_name
    email = Faker::Internet.email
    password  = "password"
    bio = Faker::Lorem.sentence[1..150]
    User.create!(first_name: first_name,
                 last_name: last_name,
                 username: username,
                 email: email,
                 password: password,
                 password_confirmation: password,
                 bio: bio,
                 :city => @cities[rand(7)].to_s)
  end
end

def make_textposts
  users = User.all(limit: 6)
  50.times do
    content = Faker::Lorem.sentence(5)
    users.each { |user| user.textposts.create!(content: content) }
  end
end

def make_relationships
  users = User.all
  user = users.first
  followed_users = users[2..50]
  followers      = users[3..40]
  followed_users.each { |followed| user.follow!(followed) }
  followers.each      { |follower| follower.follow!(user) }
end

def make_comments
  users = User.all(limit: 6)
  50.times do 
    content = Faker::Lorem.sentence(5)
    users.each { |user| user.comments.create!(content: content, textpost_id: rand(300)) }
  end
end

def make_messages
  first_user = User.first
  last_user = User.last
  message = first_user.send_message(last_user, "Hey, how are you?")
  last_user.reply_to(message, "Im good and you?")
  first_user.reply_to(message, "Im fine, thanks.")
  first_user.reply_to(message, "What are you doing today?")
  last_user.reply_to(message, "Nothing much.")
end

def make_likes
  users = User.all
  first_user = users.first
  followers = users[2..20]
  5.times do |n|
    followers.each { |follower| first_user.textposts[n].liked_by follower }
  end
end