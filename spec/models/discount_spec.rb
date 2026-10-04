require "rails_helper"

RSpec.describe Discount, type: :model do
  describe "associations" do
    it { should belong_to(:product) }
  end

  describe "validations" do
    it { should validate_numericality_of(:discount_amount).only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
    it "rejects a discount above 100%" do
      expect(build(:discount, discount_amount: 150)).not_to be_valid
    end
  end

  it "persists via factory" do
    expect(create(:discount)).to be_persisted
  end
end
