require "rails_helper"

RSpec.describe "Api::Employees", type: :request do
  let(:user) { create(:user) }
  let(:headers) { { "Authorization" => "Bearer #{JsonWebToken.encode({ user_id: user.id })}" } }

  describe "authentication" do
    it "rejects requests without a token" do
      get "/api/employees"
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects requests with an invalid token" do
      get "/api/employees", headers: { "Authorization" => "Bearer garbage" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/employees" do
    before do
      create(:employee, first_name: "Priya", last_name: "Nair", email: "priya@acme.example",
                         country: "India", department: "Engineering", salary_cents: 20_00_000)
      create(:employee, first_name: "Sam", last_name: "Ortiz", email: "sam@acme.example",
                         country: "United States", department: "Sales", salary_cents: 80_000_00)
    end

    it "lists employees with pagination metadata" do
      get "/api/employees", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json["employees"].length).to eq(2)
      expect(json["meta"]).to include("current_page" => 1, "total_count" => 2)
    end

    it "searches by name" do
      get "/api/employees", params: { q: "priya" }, headers: headers

      expect(json["employees"].map { |e| e["email"] }).to eq([ "priya@acme.example" ])
    end

    it "filters by country" do
      get "/api/employees", params: { country: "India" }, headers: headers

      expect(json["employees"].map { |e| e["email"] }).to eq([ "priya@acme.example" ])
    end

    it "filters by department" do
      get "/api/employees", params: { department: "Sales" }, headers: headers

      expect(json["employees"].map { |e| e["email"] }).to eq([ "sam@acme.example" ])
    end

    it "sorts by salary descending" do
      get "/api/employees", params: { sort_by: "salary_cents", sort_dir: "desc" }, headers: headers

      expect(json["employees"].map { |e| e["email"] }).to eq([ "sam@acme.example", "priya@acme.example" ])
    end

    it "paginates results" do
      get "/api/employees", params: { per_page: 1, page: 2 }, headers: headers

      expect(json["employees"].length).to eq(1)
      expect(json["meta"]).to include("current_page" => 2, "total_pages" => 2)
    end
  end

  describe "GET /api/employees/:id" do
    it "returns the employee" do
      employee = create(:employee)

      get "/api/employees/#{employee.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json["email"]).to eq(employee.email)
    end

    it "returns 404 for an unknown id" do
      get "/api/employees/999999", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/employees" do
    it "creates an employee with valid params" do
      params = {
        employee: {
          first_name: "Ada", last_name: "Lovelace", email: "ada@acme.example",
          country: "United Kingdom", department: "Engineering", job_title: "Analyst",
          salary: 95_000, hired_on: "2023-01-15"
        }
      }

      post "/api/employees", params: params, headers: headers

      expect(response).to have_http_status(:created)
      expect(json["email"]).to eq("ada@acme.example")
      expect(json["currency"]).to eq("GBP")
    end

    it "returns errors for invalid params" do
      params = { employee: { first_name: "", email: "not-an-email" } }

      post "/api/employees", params: params, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["errors"]).to be_present
    end
  end

  describe "PATCH /api/employees/:id" do
    it "updates the employee's salary" do
      employee = create(:employee, salary_cents: 50_000_00)

      patch "/api/employees/#{employee.id}", params: { employee: { salary: 60_000 } }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json["salary"]).to eq(60_000.0)
      expect(employee.reload.salary_cents).to eq(60_000_00)
    end
  end

  describe "DELETE /api/employees/:id" do
    it "removes the employee" do
      employee = create(:employee)

      delete "/api/employees/#{employee.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(Employee.exists?(employee.id)).to be false
    end
  end

  def json
    JSON.parse(response.body)
  end
end
