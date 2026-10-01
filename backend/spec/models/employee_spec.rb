require "rails_helper"

RSpec.describe Employee, type: :model do
  subject(:employee) { build(:employee) }

  it "is valid with valid attributes" do
    expect(employee).to be_valid
  end

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:job_title) }
  it { is_expected.to validate_presence_of(:hired_on) }

  it "rejects a hire date in the future" do
    employee.hired_on = Date.tomorrow
    expect(employee).not_to be_valid
    expect(employee.errors[:hired_on]).to include("cannot be in the future")
  end

  it "accepts a hire date of today" do
    employee.hired_on = Date.current
    expect(employee).to be_valid
  end

  it "requires a unique email, case-insensitively" do
    create(:employee, email: "dup@acme.example")
    duplicate = build(:employee, email: "DUP@acme.example")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email]).to be_present
  end

  it "rejects malformed emails" do
    employee.email = "not-an-email"
    expect(employee).not_to be_valid
  end

  it "requires the country to be one of the supported countries" do
    employee.country = "Narnia"
    expect(employee).not_to be_valid
  end

  it "requires the department to be one of the supported departments" do
    employee.department = "Wizardry"
    expect(employee).not_to be_valid
  end

  it "requires a positive integer salary" do
    employee.salary_cents = 0
    expect(employee).not_to be_valid

    employee.salary_cents = -100
    expect(employee).not_to be_valid
  end

  it "auto-assigns the currency from the country when not set" do
    employee = build(:employee, country: "Germany", currency: nil)
    employee.valid?
    expect(employee.currency).to eq("EUR")
  end

  it "rejects a currency that doesn't match the country" do
    employee.country = "Germany"
    employee.currency = "USD"
    expect(employee).not_to be_valid
  end

  describe "#full_name" do
    it "combines first and last name" do
      employee.first_name = "Ada"
      employee.last_name = "Lovelace"
      expect(employee.full_name).to eq("Ada Lovelace")
    end
  end

  describe "#salary and #salary=" do
    it "converts between dollars and cents" do
      employee.salary = 123.45
      expect(employee.salary_cents).to eq(12_345)
      expect(employee.salary).to eq(123.45)
    end
  end

  describe ".search" do
    it "matches by first name, last name, or email, case-insensitively" do
      match = create(:employee, first_name: "Priya", last_name: "Nair", email: "priya@acme.example")
      create(:employee, first_name: "Sam", last_name: "Ortiz", email: "sam@acme.example")

      expect(Employee.search("priya")).to contain_exactly(match)
      expect(Employee.search("NAIR")).to contain_exactly(match)
      expect(Employee.search("")).to include(match)
    end
  end

  describe ".in_country and .in_department" do
    it "filters by country and department when present" do
      us_eng = create(:employee, country: "United States", department: "Engineering")
      create(:employee, country: "India", department: "Sales", email: "other@acme.example")

      expect(Employee.in_country("United States")).to contain_exactly(us_eng)
      expect(Employee.in_department("Engineering")).to contain_exactly(us_eng)
      expect(Employee.in_country(nil)).to include(us_eng)
    end
  end
end
