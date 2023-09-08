class CreateOfferTypesProduct < ActiveRecord::Migration[7.0]
  def change
    create_table :offer_types_products do |t|
			t.references :product
    	t.references :offer_type
      t.timestamps
    end
  end
end
