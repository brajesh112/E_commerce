class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
    	t.string :payment_id
    	t.references :order
    	t.integer :status
      t.timestamps
    end
  end
end
