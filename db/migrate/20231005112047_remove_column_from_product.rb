class RemoveColumnFromProduct < ActiveRecord::Migration[7.0]
  def change
  	remove_column :products, :sub_sub_category_id, :integer
  end
end
