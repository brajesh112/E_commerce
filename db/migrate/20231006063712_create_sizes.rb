class CreateSizes < ActiveRecord::Migration[7.0]
  def change
    create_table :sizes do |t|
    	t.references :product
    	t.references :product_size
      t.timestamps
    end
  end
end
