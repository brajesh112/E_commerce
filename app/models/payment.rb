class Payment < ApplicationRecord
	belongs_to :order
	enum :status, [:success, :failed]
end
