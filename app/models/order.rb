class Order < ApplicationRecord
	belongs_to :user
	serialize :product_ids, Array
	belongs_to :address
	enum :payment_method, [:cash, :card, :upi]
	enum :status, [:pending, :paid, :cancel, :refunded]
	has_one :shipment, dependent: :destroy
	after_create :create_shipment

	def create_shipment
		self.build_shipment(status: "ordered", expected_delivery: DateTime.current.to_date + 7.days).save
	end

end