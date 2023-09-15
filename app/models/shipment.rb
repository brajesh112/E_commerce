class Shipment < ApplicationRecord
	include ApplicationHelper
	belongs_to :order
	enum :status, [:ordered, :shipped, :out_for_delivery, :arriving, :delivered]
	validates :status, :expected_delivery, presence: true
	has_many :tracking_orders, dependent: :destroy
	has_many :notifications, as: :notificable
	after_update :notification_method

	private
		def notification_method
			add_notification(self.order, "Your order is #{self.status}")
		end
end
