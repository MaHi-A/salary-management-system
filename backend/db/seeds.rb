# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

hr_email = ENV.fetch("HR_USER_EMAIL", "hr@acme.example")
hr_password = ENV.fetch("HR_USER_PASSWORD", "password123")

# find_or_initialize_by + always setting the password (rather than
# find_or_create_by! with the password only set on creation) means a
# password rotation via HR_USER_PASSWORD takes effect just by re-running
# this - no shell access to the deployed environment needed, which
# matters on hosts (e.g. Render's free tier) that don't offer one.
user = User.find_or_initialize_by(email: hr_email)
user.password = hr_password
user.save!

puts "HR login ready: #{hr_email} / #{hr_password}"

# --- Employees --------------------------------------------------------------
# Generates a synthetic but realistic-looking 10,000-employee roster: salary
# varies by department (role seniority) and by country (a rough numeric
# stand-in for cost-of-living/FX, since these are local-currency amounts, not
# USD-normalized ones - see docs/design-notes.md).

TARGET_EMPLOYEE_COUNT = 10_000

if Employee.count >= TARGET_EMPLOYEE_COUNT
  puts "Employees already seeded (#{Employee.count} rows) - skipping."
else
  DEPARTMENT_TITLES = {
    "Engineering" => [ "Software Engineer", "Senior Software Engineer", "Engineering Manager", "QA Engineer", "DevOps Engineer" ],
    "Sales" => [ "Account Executive", "Sales Manager", "Sales Development Rep", "Regional Sales Director" ],
    "Marketing" => [ "Marketing Specialist", "Content Strategist", "Marketing Manager", "SEO Analyst" ],
    "Finance" => [ "Financial Analyst", "Accountant", "Finance Manager", "Payroll Specialist" ],
    "Human Resources" => [ "HR Generalist", "Recruiter", "HR Business Partner", "People Operations Manager" ],
    "Operations" => [ "Operations Analyst", "Operations Manager", "Logistics Coordinator", "Facilities Manager" ]
  }.freeze

  DEPARTMENT_BASE_SALARY = {
    "Engineering" => 110_000,
    "Sales" => 90_000,
    "Marketing" => 85_000,
    "Finance" => 95_000,
    "Human Resources" => 75_000,
    "Operations" => 70_000
  }.freeze

  # Rough local-currency scale factor relative to the USD base salaries above.
  COUNTRY_SALARY_SCALE = {
    "United States" => 1.0,
    "United Kingdom" => 0.8,
    "Canada" => 1.35,
    "Germany" => 0.92,
    "France" => 0.92,
    "India" => 83.0,
    "Australia" => 1.5,
    "Singapore" => 1.35
  }.freeze

  countries = Employee::COUNTRIES
  departments = Employee::DEPARTMENTS
  now = Time.current

  puts "Seeding #{TARGET_EMPLOYEE_COUNT} employees..."

  TARGET_EMPLOYEE_COUNT.times.each_slice(1_000) do |batch_indexes|
    rows = batch_indexes.map do |i|
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      country = countries.sample
      department = departments.sample
      job_title = DEPARTMENT_TITLES[department].sample
      currency = Employee::COUNTRY_CURRENCIES[country]

      variance = rand(0.75..1.35)
      salary_cents = (DEPARTMENT_BASE_SALARY[department] * COUNTRY_SALARY_SCALE[country] * variance * 100).round

      {
        first_name: first_name,
        last_name: last_name,
        email: "#{first_name.downcase}.#{last_name.downcase}#{i}@acme.example",
        country: country,
        department: department,
        job_title: job_title,
        salary_cents: salary_cents,
        currency: currency,
        hired_on: rand(8 * 365).days.ago.to_date,
        created_at: now,
        updated_at: now
      }
    end

    Employee.insert_all(rows)
  end

  puts "Seeded #{Employee.count} employees."
end
