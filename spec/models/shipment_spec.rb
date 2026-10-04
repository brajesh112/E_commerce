require "rails_helper"

RSpec.describe Shipment, type: :model do
  describe "associations" do
    it { should belong_to(:order) }
    it { should have_many(:tracking_orders).dependent(:destroy) }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values([:ordered, :shipped, :out_for_delivery, :arriving, :delivered]) }
  end

  describe "validations" do
    subject { build(:shipment) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:expected_delivery) }
  end

  describe "#create_tracking_order (after_create)" do
    it "creates a tracking order from the seller's address city" do
      shipment = create(:shipment)
      expect(shipment.tracking_orders.count).to eq(1)
      expect(shipment.tracking_orders.first.status).to eq("ordered")
    end
  end

  describe "notification on update" do
    it "creates a notification when status changes" do
      shipment = create(:shipment)
      expect {
        shipment.update!(status: :shipped)
      }.to have_enqueued_job(PushNotificationJob)
    end
  end
end
