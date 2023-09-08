class RemoveCategoriesFromProducts < ActiveRecord::Migration[7.0]
  def change
  	remove_column :products, :categories, :integer
  end
end
