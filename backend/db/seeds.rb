# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

hr_email = ENV.fetch("HR_USER_EMAIL", "hr@acme.example")
hr_password = ENV.fetch("HR_USER_PASSWORD", "password123")

User.find_or_create_by!(email: hr_email) do |user|
  user.password = hr_password
end

puts "HR login ready: #{hr_email} / #{hr_password}"
