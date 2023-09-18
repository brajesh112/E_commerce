class AddDiscountPriceToProduct < ActiveRecord::Migration[7.0]
  def change
  	add_column :products, :discount_price, :decimal
  end
end
