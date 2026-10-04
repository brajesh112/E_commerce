class AddRazorpayToPaymentsAndOrders < ActiveRecord::Migration[8.0]
  def change
    # Which gateway processes this order's online payment (nil for cash).
    add_column :orders, :gateway, :string

    # The payments ledger now spans both gateways. Existing rows are Stripe.
    add_column :payments, :gateway, :string, default: "stripe"
    add_column :payments, :razorpay_payment_link_id, :string
    add_index :payments, :razorpay_payment_link_id
  end
end
