class RemoveProductIdsFromOrder < ActiveRecord::Migration[7.0]
  def change
  	remove_column :orders, :product_ids, :text, array: true
  end
end
