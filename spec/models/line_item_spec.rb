require "rails_helper"

RSpec.describe LineItem, type: :model do
  describe "table name" do
    it "maps to the items table" do
      expect(LineItem.table_name).to eq("items")
    end
  end

  describe "associations" do
    it { should belong_to(:cart) }
    it { should belong_to(:product) }
  end

  describe "validations" do
    it "is valid with a positive quantity" do
      expect(build(:line_item, quantity: 1)).to be_valid
    end

    it "is invalid with a zero quantity" do
      expect(build(:line_item, quantity: 0)).not_to be_valid
    end

    it "is invalid with a negative quantity" do
      expect(build(:line_item, quantity: -5)).not_to be_valid
    end
  end
end
