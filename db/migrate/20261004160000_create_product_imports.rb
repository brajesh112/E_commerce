class CreateProductImports < ActiveRecord::Migration[8.0]
  def change
    create_table :product_imports do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.integer :created_count, null: false, default: 0
      t.jsonb :row_errors, null: false, default: []

      t.timestamps
    end
  end
end
