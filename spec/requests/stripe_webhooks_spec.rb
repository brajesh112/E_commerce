require "rails_helper"
require "ostruct"

RSpec.describe "StripeWebhooks", type: :request do
  let(:headers) do
    { "HTTP_STRIPE_SIGNATURE" => "sig", "CONTENT_TYPE" => "application/json" }
  end

  # Build a fake Stripe event. `event_id` defaults to a unique value so the
  # webhook's de-dup log treats each as new unless we reuse one on purpose.
  def stub_event(type:, object:, event_id: "evt_#{SecureRandom.hex(4)}")
    allow(Stripe::Webhook).to receive(:construct_event).and_return(
      OpenStruct.new(id: event_id, type: type, data: OpenStruct.new(object: OpenStruct.new(object)))
    )
  end

  def deliver
    post "/stripe/webhook", params: "{}", headers: headers
  end

  describe "POST /stripe/webhook" do
    it "returns 400 on an invalid signature" do
      allow(Stripe::Webhook).to receive(:construct_event)
        .and_raise(Stripe::SignatureVerificationError.new("bad", "sig"))
      deliver
      expect(response).to have_http_status(:bad_request)
    end

    context "checkout.session.completed with payment_status paid" do
      it "marks the order paid and records a success payment" do
        order = create(:order, status: :pending)
        stub_event(type: "checkout.session.completed",
                   object: { id: "cs_1", payment_status: "paid",
                             client_reference_id: order.id, payment_intent: "pi_abc" })

        expect { deliver }
          .to change { order.reload.status }.from("pending").to("paid")
          .and change(order.payments, :count).by(1)

        expect(response).to have_http_status(:ok)
        payment = order.payments.last
        expect(payment.payment_id).to eq("pi_abc")
        expect(payment.stripe_session_id).to eq("cs_1")
        expect(payment).to be_success
      end

      it "updates the pending payment row rather than adding a new one" do
        order = create(:order, status: :pending)
        create(:payment, :pending, order: order, stripe_session_id: "cs_1")
        stub_event(type: "checkout.session.completed",
                   object: { id: "cs_1", payment_status: "paid",
                             client_reference_id: order.id, payment_intent: "pi_abc" })

        expect { deliver }.not_to change(order.payments, :count)
        expect(order.payments.last).to be_success
      end

      it "is idempotent on a redelivered event id" do
        order = create(:order, status: :pending)
        stub_event(type: "checkout.session.completed", event_id: "evt_same",
                   object: { id: "cs_1", payment_status: "paid",
                             client_reference_id: order.id, payment_intent: "pi_abc" })

        deliver
        expect { deliver }.not_to change(Payment, :count)
        expect(response).to have_http_status(:ok)
      end

      it "ignores an unpaid completed session" do
        order = create(:order, status: :pending)
        stub_event(type: "checkout.session.completed",
                   object: { id: "cs_1", payment_status: "unpaid",
                             client_reference_id: order.id, payment_intent: "pi_abc" })
        deliver
        expect(order.reload.status).to eq("pending")
      end
    end

    context "checkout.session.expired" do
      it "fails the order, records a failed payment, and restocks" do
        order = create(:order, status: :pending)
        product = create(:product, stock: 5)
        create(:order_item, order: order, product: product, quantity: 3)
        stub_event(type: "checkout.session.expired",
                   object: { id: "cs_1", client_reference_id: order.id })

        expect { deliver }.to change { product.reload.stock }.from(5).to(8)
        expect(order.reload.status).to eq("payment_failed")
        expect(order.payments.last).to be_failed
      end
    end

    context "charge.refunded" do
      it "confirms a refund_pending order as refunded" do
        order = create(:order, status: :refund_pending)
        create(:payment, order: order, payment_id: "pi_abc", status: :success)
        stub_event(type: "charge.refunded", object: { payment_intent: "pi_abc" })

        deliver
        expect(order.reload.status).to eq("refunded")
        expect(order.payments.find_by(payment_id: "pi_abc")).to be_refunded
      end
    end
  end
end
