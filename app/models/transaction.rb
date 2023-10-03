class Transaction < ApplicationRecord
	belongs_to :user
	belongs_to :order
	enum :status, [:pending, :paid]
end
