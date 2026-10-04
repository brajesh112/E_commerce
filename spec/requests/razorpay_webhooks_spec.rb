require "rails_helper"

RSpec.describe "RazorpayWebhooks", type: :request do
  let(:headers) { { "X-Razorpay-Signature" => "sig", "CONTENT_TYPE" => "application/json" } }

  def accept_signature
    allow(Razorpay::Utility).to receive(:verify_webhook_signature).and_return(true)
  end

  def deliver(body)
    post "/razorpay/webhook", params: body.to_json, headers: headers
  end

  def link_event(type, order, link_id: "plink_1", payment_id: "pay_1")
    {
      "event" => type,
      "payload" => {
        "payment_link" => { "entity" => { "id" => link_id, "reference_id" => order.id.to_s } },
        "payment" => { "entity" => { "id" => payment_id } }
      }
    }
  end

  describe "POST /razorpay/webhook" do
    it "returns 400 on an invalid signature" do
      allow(Razorpay::Utility).to receive(:verify_webhook_signature)
        .and_raise(SecurityError.new("bad"))
      deliver({})
      expect(response).to have_http_status(:bad_request)
    end

    context "payment_link.paid" do
      it "marks the order paid and records a success payment" do
        accept_signature
        order = create(:order, status: :pending, gateway: "razorpay")
        create(:payment, :pending, :razorpay, order: order, razorpay_payment_link_id: "plink_1")

        expect { deliver(link_event("payment_link.paid", order)) }
          .to change { order.reload.status }.from("pending").to("paid")

        payment = order.payments.last
        expect(payment).to be_success
        expect(payment.payment_id).to eq("pay_1")
        expect(response).to have_http_status(:ok)
      end

      it "is idempotent when the order is already paid" do
        accept_signature
        order = create(:order, status: :paid, gateway: "razorpay")
        create(:payment, :razorpay, order: order, status: :success, razorpay_payment_link_id: "plink_1")

        expect { deliver(link_event("payment_link.paid", order)) }
          .not_to change { order.payments.count }
      end
    end

    context "payment_link.expired" do
      it "fails the order, records a failed payment, and restocks" do
        accept_signature
        order = create(:order, status: :pending, gateway: "razorpay")
        product = create(:product, stock: 4)
        create(:order_item, order: order, product: product, quantity: 2)
        create(:payment, :pending, :razorpay, order: order, razorpay_payment_link_id: "plink_1")

        expect { deliver(link_event("payment_link.expired", order)) }
          .to change { product.reload.stock }.from(4).to(6)
        expect(order.reload.status).to eq("payment_failed")
        expect(order.payments.last).to be_failed
      end
    end

    context "refund.processed" do
      it "marks the payment and order refunded" do
        accept_signature
        order = create(:order, status: :refund_pending, gateway: "razorpay")
        create(:payment, :razorpay, order: order, status: :success, payment_id: "pay_1")
        body = { "event" => "refund.processed",
                 "payload" => { "refund" => { "entity" => { "payment_id" => "pay_1" } } } }

        deliver(body)
        expect(order.reload.status).to eq("refunded")
        expect(order.payments.find_by(payment_id: "pay_1")).to be_refunded
      end
    end
  end
end
