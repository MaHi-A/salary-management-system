require "rails_helper"

RSpec.describe "Api::Sessions", type: :request do
  describe "POST /api/login" do
    let!(:user) { create(:user, email: "hr@acme.example", password: "password123") }

    it "returns a token for valid credentials" do
      post "/api/login", params: { email: "hr@acme.example", password: "password123" }

      expect(response).to have_http_status(:created)
      expect(json["token"]).to be_present
      expect(json["email"]).to eq("hr@acme.example")
    end

    it "matches email case-insensitively" do
      post "/api/login", params: { email: "HR@ACME.EXAMPLE", password: "password123" }

      expect(response).to have_http_status(:created)
    end

    it "rejects an unknown email" do
      post "/api/login", params: { email: "nobody@acme.example", password: "password123" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects a wrong password" do
      post "/api/login", params: { email: "hr@acme.example", password: "wrong" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  def json
    JSON.parse(response.body)
  end
end
