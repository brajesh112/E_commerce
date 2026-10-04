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
    it { should validate_presence_of(:stripe_session_id) }
    it { should validate_uniqueness_of(:payment_id).allow_nil }

    it "allows a pending payment with no payment_id" do
      expect(build(:payment, :pending)).to be_valid
    end
  end

  it "persists via factory" do
    expect(create(:payment)).to be_persisted
  end
end
