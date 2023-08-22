class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.bigint :quantity
      t.references :cart
      t.references :product
      t.timestamps
    end
  end
end
