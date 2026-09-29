require "rails_helper"

RSpec.describe "Api::Stats", type: :request do
  let(:user) { create(:user) }
  let(:headers) { { "Authorization" => "Bearer #{JsonWebToken.encode({ user_id: user.id })}" } }

  describe "GET /api/stats" do
    before do
      create(:employee, email: "a@acme.example", country: "India", department: "Engineering", salary_cents: 100_00)
      create(:employee, email: "b@acme.example", country: "India", department: "Engineering", salary_cents: 300_00)
      create(:employee, email: "c@acme.example", country: "United States", department: "Sales", salary_cents: 200_00)
    end

    it "requires authentication" do
      get "/api/stats"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns overall headcount and payroll" do
      get "/api/stats", headers: headers

      expect(json["total_headcount"]).to eq(3)
      expect(json["total_payroll"]).to eq(600.0)
    end

    it "breaks down averages by country" do
      get "/api/stats", headers: headers

      india = json["by_country"].find { |row| row["country"] == "India" }
      expect(india["headcount"]).to eq(2)
      expect(india["average_salary"]).to eq(200.0)
      expect(india["min_salary"]).to eq(100.0)
      expect(india["max_salary"]).to eq(300.0)
    end

    it "breaks down averages by department" do
      get "/api/stats", headers: headers

      sales = json["by_department"].find { |row| row["department"] == "Sales" }
      expect(sales["headcount"]).to eq(1)
      expect(sales["average_salary"]).to eq(200.0)
    end
  end

  def json
    JSON.parse(response.body)
  end
end
