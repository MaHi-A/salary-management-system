require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it "is valid with valid attributes" do
    expect(user).to be_valid
  end

  it { is_expected.to validate_presence_of(:email) }

  it "requires a unique email, case-insensitively" do
    create(:user, email: "dup@acme.example")
    duplicate = build(:user, email: "DUP@acme.example")

    expect(duplicate).not_to be_valid
  end

  it "rejects malformed emails" do
    user.email = "not-an-email"
    expect(user).not_to be_valid
  end

  it "requires a password of at least 8 characters" do
    user.password = "short"
    expect(user).not_to be_valid
  end

  it "authenticates with the correct password" do
    user.save!
    expect(user.authenticate("password123")).to eq(user)
    expect(user.authenticate("wrong")).to be_falsey
  end
end
