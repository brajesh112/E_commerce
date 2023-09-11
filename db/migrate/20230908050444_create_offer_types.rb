class CreateOfferTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :offer_types do |t|
    	t.string :name
    	t.string :discount_percent
      t.timestamps
    end
  end
end
