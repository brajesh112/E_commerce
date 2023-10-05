class RemovePropertyFromProduct < ActiveRecord::Migration[7.0]
  def change
  	remove_column :products, :property_id, :integer
  	remove_column :products, :property, :integer
  end
end
