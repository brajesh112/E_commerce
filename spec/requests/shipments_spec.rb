require "rails_helper"

RSpec.describe "Shipments", type: :request do
  let(:user) { create(:user) }

  describe "GET /shipments (index)" do
    it "returns 200 for a signed-in buyer" do
      sign_in user
      get shipments_path
      expect(response).to have_http_status(:ok)
    end

    it "redirects unauthenticated users to sign in" do
      get shipments_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /shipments/:id (show)" do
    it "returns 200 for an existing shipment" do
      sign_in user
      shipment = create(:shipment)
      get shipment_path(shipment)
      expect(response).to have_http_status(:ok)
    end

    it "redirects with alert for a missing shipment" do
      sign_in user
      get shipment_path(0)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Shipment not found")
    end
  end
end
