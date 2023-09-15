class Order < ApplicationRecord
	belongs_to :user
	belongs_to :address
	enum :payment_method, [:cash, :card, :upi]
	enum :status, [:pending, :paid, :cancel, :refunded]
	has_one :shipment, dependent: :destroy
	after_create :create_shipment
	has_many :notifications, as: :notificable
	has_and_belongs_to_many :products
	paginates_per 1

	def create_shipment
		self.build_shipment(status: "ordered", expected_delivery: DateTime.current.to_date + 7.days).save
	end
	def show_model
		add = self.address
		s ="House No: #{add.house_no},<br /> Street: #{add.street},<br /> Landmark: #{add.landmark}, <br />City: #{add.city},<br />Pincode: #{add.pin},<br />State: #{add.state},<br /> Country: #{add.country}"
	end
	def discount_prices(product,quantity)
		(product.price - (product.price * product.discount.discount_amount)/100)* quantity
	end
	def discount_price(item)
		(item.product.price - (item.product.price * item.product.discount.discount_amount)/100)* item.quantity
	end
end