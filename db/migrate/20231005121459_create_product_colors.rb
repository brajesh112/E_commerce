class CreateProductColors < ActiveRecord::Migration[7.0]
  def change
    create_table :product_colors do |t|
    	t.references :product
    	t.string :color
      t.timestamps
    end
  end
end
