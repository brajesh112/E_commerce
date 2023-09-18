class CreateTermsAndConditions < ActiveRecord::Migration[7.0]
  def change
    create_table :terms_and_conditions do |t|
    	t.text :terms
      t.timestamps
    end
  end
end
