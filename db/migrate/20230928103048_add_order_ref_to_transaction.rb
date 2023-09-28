class AddOrderRefToTransaction < ActiveRecord::Migration[7.0]
  def change
  	add_reference :transactions, :order
  end
end
