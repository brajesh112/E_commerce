class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
    	t.string :categories_type
      t.timestamps
    end
  end
end
