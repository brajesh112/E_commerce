class Shipment < ApplicationRecord
	include ApplicationHelper
	belongs_to :order
	enum :status, [:ordered, :shipped, :out_for_delivery, :arriving, :delivered]
	validates :status, :expected_delivery, presence: true
	has_many :tracking_orders, dependent: :destroy
	has_many :notifications, as: :notificable
	after_update :notification_method
	after_create :create_tracking_order

	private
		def notification_method
			add_notification(self.order, "Your order is #{self.status}")
		end

		def create_tracking_order
			city = self.order.products.first.user.addresses.first.city
			self.tracking_orders.new(status: self.status, place: city).save
		end
end
