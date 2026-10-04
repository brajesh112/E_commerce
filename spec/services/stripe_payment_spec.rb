require "rails_helper"

RSpec.describe StripePayment do
  describe ".create_customer" do
    it "creates a Stripe customer with the user email and name" do
      user = create(:user, email: "buyer@example.com", name: "Jane Buyer")
      customer = double("Stripe::Customer", id: "cus_123")
      allow(Stripe::Customer).to receive(:create).and_return(customer)

      result = described_class.create_customer(user)

      expect(Stripe::Customer).to have_received(:create)
        .with(email: "buyer@example.com", name: "Jane Buyer")
      expect(result).to eq(customer)
      expect(result.id).to eq("cus_123")
    end
  end

  describe ".checkout_session" do
    it "creates a checkout session passing the order id as client_reference_id" do
      user = create(:user)
      allow(user).to receive(:stripe_id).and_return("cus_abc")
      order = create(:order)
      product = create(:product, price_id: "price_xyz")
      item = double("line_item", product: product, quantity: 3)

      customer = double("Stripe::Customer", id: "cus_abc")
      allow(Stripe::Customer).to receive(:retrieve).and_return(customer)
      session = double("Stripe::Checkout::Session", id: "cs_1")
      allow(Stripe::Checkout::Session).to receive(:create).and_return(session)

      result = described_class.checkout_session(user, [item], order)

      expect(Stripe::Customer).to have_received(:retrieve).with("cus_abc")
      expect(Stripe::Checkout::Session).to have_received(:create) do |args|
        expect(args[:client_reference_id]).to eq(order.id)
        expect(args[:customer]).to eq(customer)
        expect(args[:mode]).to eq("payment")
        expect(args[:line_items]).to eq([[{ price: "price_xyz", quantity: 3 }]])
      end
      expect(result).to eq(session)
    end
  end

  describe ".create_product" do
    it "creates a Stripe product then a price using discount_price * 100" do
      product = create(:product, product_name: "Widget", discount_price: 90)
      stripe_product = double("Stripe::Product", id: "prod_1")
      allow(Stripe::Product).to receive(:create).and_return(stripe_product)
      allow(Stripe::Price).to receive(:create).and_return(double("Stripe::Price", id: "price_1"))

      described_class.create_product(product)

      expect(Stripe::Product).to have_received(:create).with(name: "Widget")
      expect(Stripe::Price).to have_received(:create)
        .with(unit_amount: 9000, currency: "inr", product: "prod_1")
    end
  end

  describe ".refund_payment" do
    it "refunds the successful payment's payment_intent" do
      order = create(:order)
      create(:payment, order: order, status: :success, payment_id: "pi_success")

      allow(Stripe::Refund).to receive(:create).and_return(double("Stripe::Refund", id: "re_1"))

      described_class.refund_payment(order)

      expect(Stripe::Refund).to have_received(:create).with(payment_intent: "pi_success")
    end
  end
end
