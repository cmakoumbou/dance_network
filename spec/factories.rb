FactoryGirl.define do
  factory :user do
    email    "factory@example.com"
    password "foobar"
    password_confirmation "foobar"
  end
end