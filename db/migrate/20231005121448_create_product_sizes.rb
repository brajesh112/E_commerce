class CreateProductSizes < ActiveRecord::Migration[7.0]
  def change
    create_table :product_sizes do |t|
    	t.references :variant
    	t.string :size
      t.timestamps
    end
  end
end
