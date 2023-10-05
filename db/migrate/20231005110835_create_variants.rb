class CreateVariants < ActiveRecord::Migration[7.0]
  def change
    create_table :variants do |t|
    	t.decimal :category_comission
    	t.string :variant_name
    	t.references :sub_category
      t.timestamps
    end
  end
end
