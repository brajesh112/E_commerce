class Order < ApplicationRecord
	belongs_to :user
	belongs_to :address
	enum :payment_method, [:cash, :card, :upi]
	enum :status, [:pending, :payment_failed, :paid, :cancel, :refunded]
	has_one :shipment, dependent: :destroy
	after_update :create_shipment
	after_update :create_transaction
	has_many :transactions
	has_many :payments,dependent: :destroy
	has_many :order_items, dependent: :destroy
	has_many :notifications, as: :notificable
	has_and_belongs_to_many :products
	paginates_per 1

	def create_shipment
		self.build_shipment(status: "ordered", expected_delivery: DateTime.current.to_date + 7.days).save if self.status.eql?("pending")
	end

	def show_model
		add = self.address
		s ="House No: #{add.house_no},<br /> Street: #{add.street},<br /> Landmark: #{add.landmark}, <br />City: #{add.city},<br />Pincode: #{add.pin},<br />State: #{add.state},<br /> Country: #{add.country}"
	end

	def create_transaction
		if self.status.eql?('paid')
			self.order_items.all.each do |item|
				@price = item.product.discount_price * item.quantity
				@admin_comision = (item.product.sub_sub_categories.category_comission * @price)/100 
				@tax = @price/50
				@seller_earnings = @price - (@admin_comision + @tax)
				item.product.user.transactions.create(admin_commision: @admin_comision, tax: @tax, seller_earning: @seller_earnings, total_amount: @price, product: item.product.product_name, order_id: self.id, quantity: item.quantity, status: 'pending')
			end
		end
	end
end