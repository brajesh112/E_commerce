class AddOrderTotalAndConstraints < ActiveRecord::Migration[8.0]
  def change
    # #16 — persist the computed order total so refunds/reporting don't recompute.
    add_column :orders, :amount, :decimal

    # #24 — a product may appear on an order only once; stops duplicate
    # `order.products << product` join rows.
    unless index_exists?(:orders_products, [:order_id, :product_id], unique: true)
      add_index :orders_products, [:order_id, :product_id], unique: true,
                name: "index_orders_products_on_order_and_product"
    end
  end
end
