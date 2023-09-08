class CreateBankAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_accounts do |t|
    	t.string :account_no
    	t.string :ifsc_code
    	t.string :bank
    	t.string :branch_name
    	t.string :city
    	t.references :user
      t.timestamps
    end
  end
end
