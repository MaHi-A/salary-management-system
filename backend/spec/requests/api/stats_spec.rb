require "rails_helper"

RSpec.describe "Api::Stats", type: :request do
  let(:user) { create(:user) }
  let(:headers) { { "Authorization" => "Bearer #{JsonWebToken.encode({ user_id: user.id })}" } }

  describe "GET /api/stats" do
    before do
      create(:employee, email: "a@acme.example", country: "India", department: "Engineering", salary_cents: 100_00)
      create(:employee, email: "b@acme.example", country: "India", department: "Engineering", salary_cents: 300_00)
      create(:employee, email: "c@acme.example", country: "United States", department: "Sales", salary_cents: 200_00)
      create(:employee, email: "d@acme.example", country: "United States", department: "Engineering", salary_cents: 400_00)
    end

    it "requires authentication" do
      get "/api/stats"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns overall headcount" do
      get "/api/stats", headers: headers

      expect(json["total_headcount"]).to eq(4)
    end

    it "breaks down pay by country, in that country's own currency" do
      get "/api/stats", headers: headers

      india = json["by_country"].find { |row| row["country"] == "India" }
      expect(india["currency"]).to eq("INR")
      expect(india["headcount"]).to eq(2)
      expect(india["total_payroll"]).to eq(400.0)
      expect(india["average_salary"]).to eq(200.0)
      expect(india["min_salary"]).to eq(100.0)
      expect(india["max_salary"]).to eq(300.0)
    end

    it "breaks down pay by department within each country, never mixing currencies" do
      get "/api/stats", headers: headers

      us_engineering = json["by_department"].find do |row|
        row["department"] == "Engineering" && row["country"] == "United States"
      end
      india_engineering = json["by_department"].find do |row|
        row["department"] == "Engineering" && row["country"] == "India"
      end

      expect(us_engineering["currency"]).to eq("USD")
      expect(us_engineering["headcount"]).to eq(1)
      expect(us_engineering["average_salary"]).to eq(400.0)

      expect(india_engineering["currency"]).to eq("INR")
      expect(india_engineering["headcount"]).to eq(2)
      expect(india_engineering["average_salary"]).to eq(200.0)
    end
  end

  def json
    JSON.parse(response.body)
  end
end
