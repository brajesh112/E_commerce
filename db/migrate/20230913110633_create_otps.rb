class CreateOtps < ActiveRecord::Migration[7.0]
  def change
    create_table :otps do |t|
    	t.integer :onetp
    	t.references :user
      t.timestamps
    end
  end
end
