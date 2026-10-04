class StripeEvent < ApplicationRecord
	# Replay-protection log for the Stripe webhook. One row per processed event id.
	validates :event_id, presence: true, uniqueness: true
end
