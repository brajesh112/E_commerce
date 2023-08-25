class Shipment < ApplicationRecord
	belongs_to :order
	enum :status, [:ordered, :shipped, :out_for_delivery, :arriving, :delivered]
	validates :status, :expected_delivery, presence: true
	has_many :tracking_orders
end