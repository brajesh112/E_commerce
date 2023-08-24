class CreateTrackingOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :tracking_orders do |t|
    	t.string :place
    	t.integer :status
    	t.references :shipment
      t.timestamps
    end
  end
end
