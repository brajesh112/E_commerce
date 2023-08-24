class Shipment < ApplicationRecord
	belongs_to :order
	enum :status, [:ordered, :shipped, :out_for_delivery, :arriving, :delivered]
	validates :status, :expected_delivery, presence: true
	has_many :tracking_orders

	after_update :create_tracking

	def create_tracking
		if self.status == "shipped"
			city = User.where(role: "admin").first.addresses.first.city
			self.tracking_orders = TrackingOrder.create(status: self.status, place: city)
		end
	end
end