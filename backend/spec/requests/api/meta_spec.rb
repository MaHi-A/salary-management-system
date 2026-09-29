require "rails_helper"

RSpec.describe "Api::Meta", type: :request do
  let(:user) { create(:user) }
  let(:headers) { { "Authorization" => "Bearer #{JsonWebToken.encode({ user_id: user.id })}" } }

  describe "GET /api/meta" do
    it "returns the supported countries and departments" do
      get "/api/meta", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json["countries"]).to eq(Employee::COUNTRIES)
      expect(json["departments"]).to eq(Employee::DEPARTMENTS)
    end
  end

  def json
    JSON.parse(response.body)
  end
end
