FactoryGirl.define do
  factory :user do
  	sequence(:first_name)  { |n| "FirstName #{n}" }
    sequence(:last_name)  { |n| "LastName #{n}" }
  	sequence(:username) { |n| "username_#{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"
  end
end