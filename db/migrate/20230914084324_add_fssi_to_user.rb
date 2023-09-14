class AddFssiToUser < ActiveRecord::Migration[7.0]
  def change
  	add_column :users, :fssi_no, :string
  end
end
