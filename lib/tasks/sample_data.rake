namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do

    @cities = ["Manchester", "Sheffield", "Leeds", "London",
                "Liverpool", "Birmingham", "Nottingham"]

    User.create!(username: "useple",
                 email: "user@example.com",
                 password: "foobar",
                 password_confirmation: "foobar")
    
    99.times do |n|
      username  = "breaker#{n}_" + Faker::Name.first_name
      email = Faker::Internet.email
      password  = "password"
      bio = Faker::Lorem.sentence[1..150]
      User.create!(username: username,
                   email: email,
                   password: password,
                   password_confirmation: password,
                   bio: bio,
                   :city => @cities[rand(7)].to_s)
    end
  end
end