FactoryBot.define do
  factory :employee do
    sequence(:email) { |n| "employee#{n}@acme.example" }
    first_name { "Jamie" }
    last_name { "Rivera" }
    country { "United States" }
    department { "Engineering" }
    job_title { "Software Engineer" }
    salary_cents { 9_500_00 }
    hired_on { Date.new(2022, 3, 1) }
  end
end
