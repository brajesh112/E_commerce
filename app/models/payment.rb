class Payment < ApplicationRecord
	belongs_to :order
	# Explicit integer mapping preserves existing rows (success=0, failed=1) while
	# adding the pending/refunded lifecycle states.
	enum :status, { success: 0, failed: 1, pending: 2, refunded: 3 }
	# payment_id (the Stripe payment_intent) doesn't exist until a charge is made,
	# so a pending row has none; the session id is the stable key at that point.
	validates :payment_id, uniqueness: true, allow_nil: true
	validates :stripe_session_id, presence: true
	validates :status, presence: true
end
