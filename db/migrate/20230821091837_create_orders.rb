class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.string :description
      t.string :payment_method
      t.string :status
      t.string :track_id
      t.references :user
      t.timestamps
    end
  end
end
