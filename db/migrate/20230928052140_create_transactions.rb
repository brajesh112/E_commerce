class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
			t.decimal :admin_commision
    	t.decimal :seller_earning
    	t.decimal :tax
    	t.decimal :total_amount
    	t.references :user
      t.timestamps
    end
  end
end
