class Employee < ApplicationRecord
  COUNTRY_CURRENCIES = {
    "United States" => "USD",
    "United Kingdom" => "GBP",
    "Canada" => "CAD",
    "Germany" => "EUR",
    "France" => "EUR",
    "India" => "INR",
    "Australia" => "AUD",
    "Singapore" => "SGD"
  }.freeze

  COUNTRIES = COUNTRY_CURRENCIES.keys.freeze

  DEPARTMENTS = [
    "Engineering",
    "Sales",
    "Marketing",
    "Finance",
    "Human Resources",
    "Operations"
  ].freeze

  EMAIL_FORMAT = /\A[^@\s]+@[^@\s]+\z/

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                     format: { with: EMAIL_FORMAT }
  validates :country, presence: true, inclusion: { in: COUNTRIES }
  validates :department, presence: true, inclusion: { in: DEPARTMENTS }
  validates :job_title, presence: true
  validates :currency, presence: true
  validates :salary_cents, presence: true,
                            numericality: { greater_than: 0, only_integer: true }
  validates :hired_on, presence: true,
                        comparison: { less_than_or_equal_to: -> { Date.current }, message: "cannot be in the future" }

  validate :currency_matches_country

  before_validation :assign_currency_from_country

  scope :search, ->(term) {
    return all if term.blank?

    sanitized = "%#{sanitize_sql_like(term)}%"
    where(
      "first_name ILIKE :term OR last_name ILIKE :term OR email ILIKE :term",
      term: sanitized
    )
  }
  scope :in_country, ->(country) { country.present? ? where(country: country) : all }
  scope :in_department, ->(department) { department.present? ? where(department: department) : all }

  def full_name
    "#{first_name} #{last_name}"
  end

  def salary
    salary_cents / 100.0
  end

  def salary=(amount)
    self.salary_cents = amount.present? ? (amount.to_f * 100).round : nil
  end

  private

  def assign_currency_from_country
    self.currency = COUNTRY_CURRENCIES[country] if country.present? && currency.blank?
  end

  def currency_matches_country
    return if country.blank? || currency.blank?

    expected = COUNTRY_CURRENCIES[country]
    errors.add(:currency, "must be #{expected} for #{country}") if expected && currency != expected
  end
end
