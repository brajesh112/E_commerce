class ExpandPaymentLedger < ActiveRecord::Migration[8.0]
  def change
    # The payments table becomes the authoritative Stripe payment-event ledger.
    add_column :payments, :stripe_session_id, :string
    add_column :payments, :amount, :decimal
    add_index :payments, :stripe_session_id

    # Webhook de-dup log: Stripe delivers at-least-once and retries.
    create_table :stripe_events do |t|
      t.string :event_id, null: false
      t.string :event_type
      t.timestamps
    end
    add_index :stripe_events, :event_id, unique: true
  end
end
