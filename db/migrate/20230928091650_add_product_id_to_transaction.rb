class AddProductIdToTransaction < ActiveRecord::Migration[7.0]
  def change
  	add_column :transactions, :product_id, :integer
  end
end
