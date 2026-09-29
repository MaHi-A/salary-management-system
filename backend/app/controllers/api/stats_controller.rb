module Api
  class StatsController < Api::BaseController
    def index
      render json: {
        total_headcount: Employee.count,
        total_payroll: cents_to_dollars(Employee.sum(:salary_cents)),
        by_country: breakdown_by(:country),
        by_department: breakdown_by(:department)
      }
    end

    private

    GROUPABLE_COLUMNS = %i[country department].freeze

    def breakdown_by(column)
      raise ArgumentError, "unsupported column: #{column}" unless GROUPABLE_COLUMNS.include?(column)

      Employee
        .group(column)
        .order(column)
        .select(
          "#{column} AS key",
          "COUNT(*) AS headcount",
          "AVG(salary_cents) AS avg_cents",
          "MIN(salary_cents) AS min_cents",
          "MAX(salary_cents) AS max_cents",
          "PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_cents) AS median_cents"
        )
        .map do |row|
          {
            column => row["key"],
            headcount: row["headcount"].to_i,
            average_salary: cents_to_dollars(row["avg_cents"]),
            median_salary: cents_to_dollars(row["median_cents"]),
            min_salary: cents_to_dollars(row["min_cents"]),
            max_salary: cents_to_dollars(row["max_cents"])
          }
        end
    end

    def cents_to_dollars(cents)
      return 0.0 if cents.nil?

      (cents.to_f / 100).round(2)
    end
  end
end
