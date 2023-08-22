class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.text :description
      t.integer :payment_method
      t.integer :status
      t.bigint :track_id
      t.references :user
      t.timestamps
    end
  end
end
