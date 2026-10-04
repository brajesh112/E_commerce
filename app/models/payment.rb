class Payment < ApplicationRecord
	belongs_to :order
	# Explicit integer mapping preserves existing rows (success=0, failed=1) while
	# adding the pending/refunded lifecycle states.
	enum :status, { success: 0, failed: 1, pending: 2, refunded: 3 }
	# payment_id (the gateway's captured-payment id) doesn't exist until a charge
	# is made, so a pending row has none; the gateway's session/link id is the
	# stable key at that point.
	validates :payment_id, uniqueness: true, allow_nil: true
	validates :status, presence: true
	validate :has_gateway_reference

	private

	# Every row must be keyed by its gateway's checkout reference: a Stripe
	# session id or a Razorpay payment-link id.
	def has_gateway_reference
		return if stripe_session_id.present? || razorpay_payment_link_id.present?
		errors.add(:base, "stripe_session_id or razorpay_payment_link_id is required")
	end
end
