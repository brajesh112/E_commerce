class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
    	t.string :product_name
    	t.bigint :stock
    	t.decimal :price
    	t.string :description
    	t.integer :categories
    	t.references :user
      t.timestamps
    end
  end
end
