class AddRefToProduct < ActiveRecord::Migration[7.0]
  def change
  	add_reference :products, :variant, null: true, foreign_key: true
  end
end
