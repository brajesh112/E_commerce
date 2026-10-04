require "rails_helper"

RSpec.describe "Payments", type: :request do
  let(:user) { create(:user) }

  describe "GET /payments/success (show)" do
    it "redirects to orders_path on success for the current user's order" do
      sign_in user
      order = create(:order, user: user)
      allow(Stripe::Checkout::Session).to receive(:retrieve)
        .and_return(double(client_reference_id: order.id))

      get payment_path("success"), params: { session_id: "cs_test_123" }
      expect(response).to redirect_to(orders_path)
    end

    it "redirects with alert when the order is not found / not owned" do
      sign_in user
      other_order = create(:order, user: create(:user))
      allow(Stripe::Checkout::Session).to receive(:retrieve)
        .and_return(double(client_reference_id: other_order.id))

      get payment_path("success"), params: { session_id: "cs_test_123" }
      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to eq("Order not found")
    end

    it "redirects with alert when Stripe raises an error" do
      sign_in user
      allow(Stripe::Checkout::Session).to receive(:retrieve)
        .and_raise(Stripe::StripeError.new("boom"))

      get payment_path("success"), params: { session_id: "cs_test_123" }
      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to be_present
    end

    it "requires authentication" do
      get payment_path("success"), params: { session_id: "cs_test_123" }
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
