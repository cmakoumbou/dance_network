namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do

    @cities = ["Manchester", "Sheffield", "Leeds", "London",
                "Liverpool", "Birmingham", "Nottingham"]

    User.create!(first_name: "Example",
                 last_name: "User",
                 username: "useple",
                 email: "user@example.com",
                 password: "foobar",
                 password_confirmation: "foobar")
    
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

    users = User.all(limit: 6)
    50.times do
      content = Faker::Lorem.sentence(5)
      users.each { |user| user.textposts.create!(content: content) }
    end
  end
end