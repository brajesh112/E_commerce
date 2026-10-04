class AddForeignKeys < ActiveRecord::Migration[8.0]
  # Referential integrity for the core associations. Each key is added only when
  # the child table has no orphan rows, so a legacy database with dangling
  # references doesn't abort the whole migration.
  FKS = [
    [:orders,      :users,     :user_id],
    [:orders,      :addresses, :address_id],
    [:order_items, :orders,    :order_id],
    [:order_items, :products,  :product_id],
    [:payments,    :orders,    :order_id],
    [:shipments,   :orders,    :order_id],
    [:carts,       :users,     :user_id],
    [:addresses,   :users,     :user_id],
    [:bank_accounts, :users,   :user_id],
  ].freeze

  def up
    FKS.each do |from, to, col|
      next if foreign_key_exists?(from, to, column: col)
      orphans = select_value(
        "SELECT COUNT(*) FROM #{from} c LEFT JOIN #{to} p ON c.#{col} = p.id " \
        "WHERE c.#{col} IS NOT NULL AND p.id IS NULL"
      ).to_i
      if orphans.zero?
        add_foreign_key from, to, column: col
      else
        say "skipping FK #{from}.#{col} -> #{to}: #{orphans} orphan row(s)"
      end
    end
  end

  def down
    FKS.each do |from, to, col|
      remove_foreign_key from, to, column: col if foreign_key_exists?(from, to, column: col)
    end
  end
end
