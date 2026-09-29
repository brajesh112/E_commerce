require "rails_helper"
require "ostruct"

RSpec.describe "StripeWebhooks", type: :request do
  let(:headers) do
    { "HTTP_STRIPE_SIGNATURE" => "sig", "CONTENT_TYPE" => "application/json" }
  end

  def event(type:, object:)
    OpenStruct.new(type: type, data: OpenStruct.new(object: OpenStruct.new(object)))
  end

  describe "POST /stripe/webhook" do
    it "returns 400 on an invalid signature" do
      allow(Stripe::Webhook).to receive(:construct_event)
        .and_raise(Stripe::SignatureVerificationError.new("bad", "sig"))
      post "/stripe/webhook", params: "{}", headers: headers
      expect(response).to have_http_status(:bad_request)
    end

    context "checkout.session.completed with payment_status paid" do
      it "marks the order paid and creates a payment (200)" do
        order = create(:order, status: :pending)
        allow(Stripe::Webhook).to receive(:construct_event).and_return(
          event(type: "checkout.session.completed",
                object: { payment_status: "paid",
                          client_reference_id: order.id,
                          payment_intent: "pi_abc" })
        )

        expect {
          post "/stripe/webhook", params: "{}", headers: headers
        }.to change { order.reload.status }.from("pending").to("paid")
          .and change(order.payments, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(order.payments.last.payment_id).to eq("pi_abc")
      end

      it "is idempotent (no duplicate payment on a second delivery)" do
        order = create(:order, status: :pending)
        allow(Stripe::Webhook).to receive(:construct_event).and_return(
          event(type: "checkout.session.completed",
                object: { payment_status: "paid",
                          client_reference_id: order.id,
                          payment_intent: "pi_abc" })
        )

        post "/stripe/webhook", params: "{}", headers: headers
        expect {
          post "/stripe/webhook", params: "{}", headers: headers
        }.not_to change(Payment, :count)
        expect(response).to have_http_status(:ok)
      end

      it "ignores an unpaid completed session" do
        order = create(:order, status: :pending)
        allow(Stripe::Webhook).to receive(:construct_event).and_return(
          event(type: "checkout.session.completed",
                object: { payment_status: "unpaid",
                          client_reference_id: order.id,
                          payment_intent: "pi_abc" })
        )
        post "/stripe/webhook", params: "{}", headers: headers
        expect(order.reload.status).to eq("pending")
        expect(response).to have_http_status(:ok)
      end
    end

    context "checkout.session.expired" do
      it "marks the order payment_failed" do
        order = create(:order, status: :pending)
        allow(Stripe::Webhook).to receive(:construct_event).and_return(
          event(type: "checkout.session.expired",
                object: { client_reference_id: order.id })
        )
        post "/stripe/webhook", params: "{}", headers: headers
        expect(order.reload.status).to eq("payment_failed")
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
