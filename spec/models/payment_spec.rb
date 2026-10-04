require "rails_helper"

RSpec.describe Payment, type: :model do
  describe "associations" do
    it { should belong_to(:order) }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values(success: 0, failed: 1, pending: 2, refunded: 3) }
  end

  describe "validations" do
    subject { create(:payment) } # uniqueness needs a persisted record
    it { should validate_uniqueness_of(:payment_id).allow_nil }

    it "allows a pending payment with no payment_id" do
      expect(build(:payment, :pending)).to be_valid
    end

    it "accepts a Razorpay row keyed by its payment-link id" do
      expect(build(:payment, :razorpay)).to be_valid
    end

    it "is invalid with neither a Stripe session nor a Razorpay link id" do
      payment = build(:payment, stripe_session_id: nil, razorpay_payment_link_id: nil)
      expect(payment).not_to be_valid
    end
  end

  it "persists via factory" do
    expect(create(:payment)).to be_persisted
  end
end
