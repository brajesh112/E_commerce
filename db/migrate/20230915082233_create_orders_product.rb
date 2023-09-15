class CreateOrdersProduct < ActiveRecord::Migration[7.0]
  def change
    create_table :orders_products do |t|
    	t.references :product
    	t.references :order
      t.timestamps
    end
  end
end
