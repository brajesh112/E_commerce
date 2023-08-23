class Order < ApplicationRecord
	belongs_to :user
	belongs_to :product 
	belongs_to :address
	enum :payment_method, [:cash, :card, :upi]
	enum :status, [:pending, :order_placed, :in_transit, :delivered]
	has_one :shipment, dependent: :destroy
	after_create :create_shipment


	def create_shipment
		self.shipment = Shipment.create(status: "ordered", expected_delivery: DateTime.current.to_date+ 7.days)
	end
end
