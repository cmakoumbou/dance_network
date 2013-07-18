namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    User.create!(first_name: "Example",
                 last_name: "User",
                 email: "user@example.com",
                 password: "foobar",
                 password_confirmation: "foobar")
    99.times do |n|
      first_name  = Faker::Name.first_name
      last_name  = Faker::Name.last_name
      email = Faker::Internet.email
      password  = "password"
      bio = Faker::Lorem.sentence[1..150]
      User.create!(first_name: first_name,
                   last_name: last_name,
                   email: email,
                   password: password,
                   password_confirmation: password,
                   bio: bio)
    end
  end
end