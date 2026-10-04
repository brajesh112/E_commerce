require "rails_helper"

RSpec.describe RazorpayPayment do
  let(:user)  { create(:user, name: "Buyer", phone_number: "9876543210") }
  let(:order) { create(:order, user: user, amount: 150) }

  describe ".payment_link" do
    it "creates an INR payment link in paise, keyed by the order id" do
      allow(Razorpay::PaymentLink).to receive(:create)
        .and_return(double(id: "plink_1", short_url: "https://rzp.io/i/abc"))

      link = described_class.payment_link(user, order)

      expect(Razorpay::PaymentLink).to have_received(:create) do |args|
        expect(args[:amount]).to eq(15000) # 150 INR -> paise
        expect(args[:currency]).to eq("INR")
        expect(args[:reference_id]).to eq(order.id.to_s)
        expect(args[:customer][:contact]).to eq("9876543210")
      end
      expect(link.short_url).to eq("https://rzp.io/i/abc")
    end
  end

  describe ".refund_payment" do
    it "refunds the captured Razorpay payment" do
      create(:payment, :razorpay, order: order, status: :success, payment_id: "pay_123")
      payment_double = double("payment")
      allow(Razorpay::Payment).to receive(:fetch).with("pay_123").and_return(payment_double)
      allow(payment_double).to receive(:refund)

      described_class.refund_payment(order)

      expect(Razorpay::Payment).to have_received(:fetch).with("pay_123")
      expect(payment_double).to have_received(:refund)
    end

    it "does nothing when there is no successful Razorpay payment" do
      expect(Razorpay::Payment).not_to receive(:fetch)
      described_class.refund_payment(order)
    end
  end
end
