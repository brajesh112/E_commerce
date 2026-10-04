require "rails_helper"

RSpec.describe "TrackingOrders", type: :request do
  let(:user) { create(:user) }

  describe "GET /tracking_orders/:id (show)" do
    it "returns 200 for a valid shipment" do
      sign_in user
      shipment = create(:shipment)
      get tracking_order_path(shipment)
      expect(response).to have_http_status(:ok)
    end

    it "redirects to root with alert for an unknown id" do
      sign_in user
      get tracking_order_path(0)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Please insert valid Id")
    end
  end
end
