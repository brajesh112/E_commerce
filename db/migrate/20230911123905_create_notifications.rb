class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
    	t.string :title
    	t.text :description
    	t.references :user
      t.timestamps
    end
  end
end
