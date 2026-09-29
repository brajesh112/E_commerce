require "rails_helper"

RSpec.describe "Orders", type: :request do
  let(:user) { create(:user) } # buyer by default

  # A product whose seller has an address, so shipment/tracking-order
  # after_create callbacks (which read product.user.addresses.first.city)
  # don't blow up when a pending order builds its shipment.
  def sellable_product
    seller = create(:user, :seller)
    create(:address, user: seller)
    create(:product, user: seller)
  end

  describe "GET /orders (index)" do
    it "returns 200 for a buyer who has orders" do
      sign_in user
      create(:order, :with_shipment, user: user)
      get orders_path
      expect(response).to have_http_status(:ok)
    end

    it "redirects to root with alert when the buyer has no orders" do
      sign_in user
      get orders_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end

    it "redirects unauthenticated users to sign in" do
      get orders_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects a non-buyer (seller) to the admin dashboard" do
      sign_in create(:user, :seller)
      get orders_path
      expect(response).to have_http_status(:redirect) # admin_dashboard_path
    end
  end

  describe "GET /orders/:id (show)" do
    it "returns 200 for the owner" do
      sign_in user
      order = create(:order, :with_shipment, user: user)
      get order_path(order)
      expect(response).to have_http_status(:ok)
    end

    it "redirects with alert for another user's order (IDOR)" do
      sign_in user
      other_order = create(:order, user: create(:user))
      get order_path(other_order)
      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to eq("Order not found")
    end
  end

  describe "POST /orders (create)" do
    it "creates a cash order and redirects to the order page" do
      sign_in user
      address = create(:address, user: user)
      product = sellable_product
      line_item = create(:line_item, cart: user.cart, product: product, quantity: 1)

      expect {
        post orders_path, params: {
          order: { address_id: address.id, payment_method: "cash", item_id: line_item.id.to_s }
        }
      }.to change(user.orders, :count).by(1)

      order = user.orders.last
      expect(response).to redirect_to(order_path(order))
      expect(order.status).to eq("pending")
    end

    it "forces status to pending even if a client supplies one" do
      sign_in user
      address = create(:address, user: user)
      product = sellable_product
      line_item = create(:line_item, cart: user.cart, product: product, quantity: 1)

      post orders_path, params: {
        order: { address_id: address.id, payment_method: "cash",
                 item_id: line_item.id.to_s, status: "paid" }
      }
      expect(user.orders.last.status).to eq("pending")
    end

    it "redirects to the Stripe checkout url for a card order" do
      sign_in user
      address = create(:address, user: user)
      product = sellable_product
      line_item = create(:line_item, cart: user.cart, product: product, quantity: 1)

      allow(StripePayment).to receive(:checkout_session)
        .and_return(double(url: "https://stripe.test/session/abc"))

      post orders_path, params: {
        order: { address_id: address.id, payment_method: "card", item_id: line_item.id.to_s }
      }
      expect(StripePayment).to have_received(:checkout_session)
      expect(response).to redirect_to("https://stripe.test/session/abc")
    end
  end

  describe "PATCH /orders/:id (update - cancel/refund)" do
    it "cancels a pending order" do
      sign_in user
      order = create(:order, user: user, status: :pending)
      patch order_path(order)
      expect(order.reload.status).to eq("cancel")
      expect(response).to redirect_to(orders_path)
    end

    it "refunds a paid order via StripePayment.refund_payment" do
      sign_in user
      order = create(:order, user: user, status: :paid)
      allow(StripePayment).to receive(:refund_payment)
      patch order_path(order)
      expect(order.reload.status).to eq("refunded")
      expect(StripePayment).to have_received(:refund_payment).with(order)
    end

    it "redirects with alert for another user's order (IDOR)" do
      sign_in user
      other_order = create(:order, user: create(:user))
      patch order_path(other_order)
      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to eq("Order not found")
    end
  end

  describe "GET /orders/:order_id/detail_pdf (order_pdf)" do
    it "returns a PDF for the owner" do
      sign_in user
      order = create(:order, user: user)
      get order_detail_pdf_path(order)
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/pdf")
    end

    it "redirects with alert for another user's order (IDOR)" do
      sign_in user
      other_order = create(:order, user: create(:user))
      get order_detail_pdf_path(other_order)
      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to eq("Order not found")
    end
  end
end
