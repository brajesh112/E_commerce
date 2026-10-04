require "rails_helper"

RSpec.describe Order, type: :model do
  describe "enums" do
    it { should define_enum_for(:payment_method).with_values([:cash, :card, :upi]) }
    it { should define_enum_for(:status).with_values([:pending, :payment_failed, :paid, :cancel, :refunded, :refund_pending]) }
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:address) }
    it { should have_one(:shipment).dependent(:destroy) }
    it { should have_many(:transactions) }
    it { should have_many(:payments).dependent(:destroy) }
    it { should have_many(:order_items).dependent(:destroy) }
    it { should have_and_belong_to_many(:products) }
  end

  describe "#show_model" do
    it "returns an HTML string built from the address" do
      order = create(:order)
      html = order.show_model
      expect(html).to include("House No:")
      expect(html).to include(order.address.house_no)
      expect(html).to include("<br />")
    end
  end

  describe "#create_shipment (after_update)" do
    it "builds a shipment when status stays pending on update" do
      order = create(:order)
      product = create(:product)
      create(:address, user: product.user)
      order.products << product
      order.update!(track_id: "NEWTRACK")
      expect(order.reload.shipment).to be_present
    end
  end

  describe "#create_transaction (after_update)" do
    it "creates seller transactions when order becomes paid" do
      order = create(:order)
      product = create(:product, discount_price: 100)
      create(:order_item, order: order, product: product, quantity: 2)
      expect {
        order.update!(status: :paid)
      }.to change { product.user.transactions.count }.by(1)

      txn = product.user.transactions.last
      # price = discount_price(100) * qty(2) = 200
      # admin_comision = comission(10) * 200 / 100 = 20 ; tax = 200/50 = 4
      expect(txn.total_amount.to_i).to eq(200)
      expect(txn.admin_commision.to_i).to eq(20)
      expect(txn.tax.to_i).to eq(4)
      expect(txn.seller_earning.to_i).to eq(176)
    end
  end

  describe "pagination" do
    it "paginates 1 per page" do
      expect(Order.default_per_page).to eq(1)
    end
  end

  describe "#restock!" do
    it "returns each order item's quantity to product stock" do
      order = create(:order)
      product = create(:product, stock: 8)
      create(:order_item, order: order, product: product, quantity: 3)

      expect { order.restock! }.to change { product.reload.stock }.from(8).to(11)
    end
  end
end
