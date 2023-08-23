class Shipment < ApplicationRecord
	belongs_to :order
	enum :status, [:ordered, :shipped, :out_for_delivery, :paid]
end
