class Order < ApplicationRecord
	# Seller earnings are split as: admin commission (per-variant %), a flat tax
	# rate, and the remainder to the seller.
	TAX_RATE = BigDecimal("0.02")

	belongs_to :user
	belongs_to :address
	enum :payment_method, [:cash, :card, :upi]
	# refund_pending = buyer asked for a refund and Stripe was called, but the
	# charge.refunded webhook hasn't confirmed yet. Appended so existing integer
	# values are unchanged.
	enum :status, [:pending, :payment_failed, :paid, :cancel, :refunded, :refund_pending]
	has_one :shipment, dependent: :destroy
	after_update :create_shipment
	after_update :create_transaction
	has_many :transactions
	has_many :payments,dependent: :destroy
	has_many :order_items, dependent: :destroy
	has_many :notifications, as: :notificable
	has_and_belongs_to_many :products
	paginates_per 1

	validates :status, presence: true

	def create_shipment
		# Build the shipment once, when the order first has a pending status.
		# Without the `shipment` guard this after_update created a duplicate
		# shipment row on every save while the order stayed pending.
		return unless status == "pending"
		return if shipment.present?
		build_shipment(status: "ordered", expected_delivery: DateTime.current.to_date + 7.days).save
	end

	# Return reserved stock to inventory when a payment expires or fails. Atomic
	# per product; safe to call only from the payment_failed transition (the
	# webhook guards against calling it twice).
	def restock!
		order_items.each do |item|
			Product.where(id: item.product_id).update_all("stock = stock + #{item.quantity.to_i}")
		end
	end

	def show_model
		add = self.address
		s ="House No: #{add.house_no},<br /> Street: #{add.street},<br /> Landmark: #{add.landmark}, <br />City: #{add.city},<br />Pincode: #{add.pin},<br />State: #{add.state},<br /> Country: #{add.country}"
	end

	def create_transaction
		# Pay sellers out exactly once, only on the transition into `paid`.
		# Previously this fired on every update (cancel/refund re-triggered it)
		# and created duplicate payout transactions.
		return unless saved_change_to_status? && status == "paid"
		return if transactions.exists?

		order_items.includes(product: [:variant, :user]).each do |item|
			unit_price = item.product.discount_price || item.product.price
			price = unit_price * item.quantity
			admin_comision = (item.product.variant.category_comission * price) / 100
			tax = price * TAX_RATE
			seller_earnings = price - (admin_comision + tax)
			item.product.user.transactions.create(
				admin_commision: admin_comision, tax: tax, seller_earning: seller_earnings,
				total_amount: price, product: item.product.product_name,
				order_id: self.id, quantity: item.quantity, status: 'pending'
			)
		end
	end
end
