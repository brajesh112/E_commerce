class Payment < ApplicationRecord
	belongs_to :order
	enum :status, [:success, :failed]
	validates :payment_id, presence: true, uniqueness: true
	validates :status, presence: true
end
