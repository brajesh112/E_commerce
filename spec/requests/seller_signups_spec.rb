require "rails_helper"

RSpec.describe "SellerSignups", type: :request do
  describe "GET /seller_signups (index)" do
    it "returns 200" do
      get seller_signups_path, params: {
        account_no: "123", ifsc_code: "HDFC0001234", bank: "HDFC",
        branch_name: "MG Road", city: "Mumbai"
      }
      expect(response).to have_http_status(:ok)
    end
  end
end
