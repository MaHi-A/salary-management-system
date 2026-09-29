FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "hr#{n}@acme.example" }
    password { "password123" }
  end
end
