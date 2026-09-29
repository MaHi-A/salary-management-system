module Api
  class StatsController < Api::BaseController
    # Employees are paid in their country's local currency (no currency
    # conversion - see docs/requirements.md). Every aggregate below is
    # therefore scoped to a single currency: by_country groups by country
    # alone (one currency per country), and by_department groups by
    # department *within* country so a department's numbers are never a
    # sum/average across different currencies.
    def index
      render json: {
        total_headcount: Employee.count,
        by_country: by_country,
        by_department: by_department
      }
    end

    private

    AGGREGATE_COLUMNS = [
      "MIN(currency) AS currency",
      "COUNT(*) AS headcount",
      "SUM(salary_cents) AS total_cents",
      "AVG(salary_cents) AS avg_cents",
      "PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_cents) AS median_cents",
      "MIN(salary_cents) AS min_cents",
      "MAX(salary_cents) AS max_cents"
    ].freeze

    def by_country
      Employee
        .group(:country)
        .order(:country)
        .select("country", *AGGREGATE_COLUMNS)
        .map { |row| aggregate_row(row, country: row["country"]) }
    end

    def by_department
      Employee
        .group(:department, :country)
        .order(:department, :country)
        .select("department", "country", *AGGREGATE_COLUMNS)
        .map { |row| aggregate_row(row, department: row["department"], country: row["country"]) }
    end

    def aggregate_row(row, **identity)
      identity.merge(
        currency: row["currency"],
        headcount: row["headcount"].to_i,
        total_payroll: cents_to_dollars(row["total_cents"]),
        average_salary: cents_to_dollars(row["avg_cents"]),
        median_salary: cents_to_dollars(row["median_cents"]),
        min_salary: cents_to_dollars(row["min_cents"]),
        max_salary: cents_to_dollars(row["max_cents"])
      )
    end

    def cents_to_dollars(cents)
      return 0.0 if cents.nil?

      (cents.to_f / 100).round(2)
    end
  end
end
