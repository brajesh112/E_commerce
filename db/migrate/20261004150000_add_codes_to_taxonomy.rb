class AddCodesToTaxonomy < ActiveRecord::Migration[8.0]
  def up
    add_column :categories, :code, :string
    add_column :sub_categories, :code, :string
    add_column :variants, :code, :string

    # Backfill existing rows with a deterministic code from their name.
    backfill(Category, :categories_type)
    backfill(SubCategory, :name)
    backfill(Variant, :variant_name)

    add_index :categories, :code, unique: true
    add_index :sub_categories, :code, unique: true
    add_index :variants, :code, unique: true
  end

  def down
    remove_column :categories, :code
    remove_column :sub_categories, :code
    remove_column :variants, :code
  end

  private

  def backfill(model, name_attr)
    used = []
    model.reset_column_information
    model.where(code: nil).find_each do |record|
      base = record.public_send(name_attr).to_s.parameterize(separator: "_").upcase
      base = "CODE" if base.blank?
      code = base
      i = 1
      while used.include?(code) || model.exists?(code: code)
        code = "#{base}_#{i}"
        i += 1
      end
      used << code
      record.update_columns(code: code)
    end
  end
end
