class CreateShipments < ActiveRecord::Migration[7.0]
  def change
    create_table :shipments do |t|
      t.integer :status
      t.datetime :expected_delivery
      t.references :order
      t.timestamps
    end
  end
end
