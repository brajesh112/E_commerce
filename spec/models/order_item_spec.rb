require "rails_helper"

RSpec.describe OrderItem, type: :model do
  describe "associations" do
    it { should belong_to(:order) }
    it { should belong_to(:product) }
  end

  describe "validations" do
    subject { build(:order_item) }
    it { should validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
    it "is invalid with zero quantity" do
      expect(build(:order_item, quantity: 0)).not_to be_valid
    end
  end

  it "persists via factory" do
    expect(create(:order_item)).to be_persisted
  end
end
