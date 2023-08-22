class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.string :city
      t.string :house_no
      t.string :street
      t.string :landmark
      t.string :state
      t.string :pin
      t.string :country
      t.references :user
      t.timestamps
    end
  end
end
