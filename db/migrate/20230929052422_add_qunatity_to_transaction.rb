class AddQunatityToTransaction < ActiveRecord::Migration[7.0]
  def change
  	add_column :transactions, :quantity, :integer
  	remove_column :transactions, :product_id, :integer
  	add_column :transactions, :product, :string
  end
end
