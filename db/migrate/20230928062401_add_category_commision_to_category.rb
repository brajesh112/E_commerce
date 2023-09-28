class AddCategoryCommisionToCategory < ActiveRecord::Migration[7.0]
  def change
  	add_column :categories, :category_comission, :decimal
  end
end
