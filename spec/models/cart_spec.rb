require "rails_helper"

RSpec.describe Cart, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:line_items).dependent(:destroy) }
  end

  describe "#cart_method" do
    let(:cart) { create(:user).cart }

    it "returns ₹40 for a national product" do
      product = build(:product, product_type: :national)
      expect(cart.cart_method(product)).to eq("₹40")
    end

    it "returns Free for a non-national product" do
      product = build(:product, product_type: :personal)
      expect(cart.cart_method(product)).to eq("Free")
    end
  end

  describe "#total_charges" do
    let(:cart) { create(:user).cart }

    it "returns 40 when the cart contains a national product" do
      create(:line_item, cart: cart, product: create(:product, product_type: :national))
      expect(cart.total_charges(cart.line_items)).to eq(40)
    end

    it "returns 'Free' when there is no national product" do
      expect(cart.total_charges(cart.line_items)).to eq("Free")
    end
  end
end
