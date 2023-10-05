class RemoveCategoryComissionFromCategory < ActiveRecord::Migration[7.0]
  def change
  	remove_column :categories, :category_comission, :decimal
  end
end
