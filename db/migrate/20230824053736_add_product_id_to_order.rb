class AddProductIdToOrder < ActiveRecord::Migration[7.0]
  def change
  	add_column :Orders, :product_ids, :text, array: true
  end
end
