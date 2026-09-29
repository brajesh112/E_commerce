require "rails_helper"

RSpec.describe TrackingOrder, type: :model do
  describe "associations" do
    it { should belong_to(:shipment) }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values([:ordered, :shipped, :out_for_delivery, :arriving, :delivered]) }
  end

  describe "validations" do
    subject { build(:tracking_order) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:place) }
  end
end
