class OrdersController < ApplicationController
	before_action :check, only: [:edit, :destroy]
	before_action :authenticate_user!
	before_action :authenticate_user
	def new
		if params[:value].present?
			current_user.cart.line_items.create(quantity: 1, product_id: params[:id]) unless current_user.cart.line_items.where(product_id: params[:id]).present?
			 @items = current_user.cart.line_items.where(product_id: params[:id])
		else
			@items = params[:item_id].to_i.eql?(0) ? current_user.cart.line_items : LineItem.where(id: params[:item_id])
		end
		 return redirect_to carts_path unless @items.present?
		 @address = current_user.addresses
		 @track = "TRC#{rand 100000..999999}"
		 @status = "pending"
		 @order = current_user.orders.new
	end

	def create
		unless params[:id].present?
			@order = current_user.orders.new(order_params)
			@order.status = "pending" # never trust a client-supplied status
			@order.gateway = resolved_gateway(@order.payment_method, params.dig(:order, :gateway))
			@items = LineItem.where(id: params[:order][:item_id].split)
			return redirect_to new_order_path, alert: "something went wrong" unless @items.present?

			begin
				build_order_with_items
			rescue OutOfStock => e
				return redirect_to carts_path, alert: "#{e.message} is out of stock"
			end
			return redirect_to new_order_path, alert: "something went wrong" unless @order.persisted?
		else
			@order = current_user.orders.find_by(id: params[:id])
			return redirect_to orders_path, alert: "Order not found" if @order.nil?
			@items = @order.order_items
		end
			unless @order.payment_method.eql?('cash')
				case @order.gateway
				when "razorpay"
					return start_razorpay_payment
				else
					return start_stripe_payment
				end
			end
			redirect_to order_path(@order)
	end

	def show
		@order = current_user.orders.find_by(id: params[:id])
		redirect_to orders_path, alert: "Order not found" if @order.nil?
	end

	def index
		orders = current_user.orders.includes(:shipment, products: :variant)
		redirect_to root_path, alert: "You have not ordered anything at" unless orders.present?
		@orders = orders.page params[:page]
	end

	def update
		@order = current_user.orders.find_by(id: params[:id])
		return redirect_to orders_path, alert: "Order not found" unless @order.present?
		if @order.status.eql?("paid")
			# Initiate the refund; the order only becomes `refunded` once the gateway
			# confirms it via webhook (charge.refunded / refund.processed).
			@order.update(status: "refund_pending", track_id: nil)
			begin
				if @order.gateway == "razorpay"
					RazorpayPayment.refund_payment(@order)
				else
					StripePayment.refund_payment(@order)
				end
			rescue Stripe::StripeError, Razorpay::Error
				@order.update(status: "paid")
				flash[:alert] = "Refund could not be started. Please try again."
			end
		else
			@order.update(status: "cancel", track_id: nil)
		end
		helpers.add_notification(@order, "Your Order Is Canceled")
		@order.shipment&.destroy
		redirect_to orders_path
	end

	def order_pdf
		order = current_user.orders.find_by(id: params[:order_id])
		return redirect_to orders_path, alert: "Order not found" if order.nil?
    send_data generate_pdf(order),
              filename: "#{order.id}.pdf",
              type: "application/pdf",
              disposition: "inline"
 #    send_file("/home/user/Downloads/#{user.user_name}.pdf",
 #              filename: "#{user.id}.pdf",
 #              type: "application/pdf")
 
	end

	private

		# Raised when a line item's product no longer has enough stock; rolls the
		# whole order creation back.
		class OutOfStock < StandardError; end

		# Create the order, its order_items, decrement stock atomically, and
		# persist the computed total — all or nothing.
		def build_order_with_items
			ActiveRecord::Base.transaction do
				@order.description = ""
				@order.products << @items.map(&:product)
				raise ActiveRecord::Rollback unless @order.save

				@description = ""
				total = 0
				@items.each_with_index do |item, idx|
					create_order_items(item, idx + 1)
					unit = item.product.discount_price || item.product.price
					total += unit * item.quantity
				end
				@order.update(description: @description, amount: total)
			end
		end

		def order_params
			params.require(:order).permit(:address_id, :payment_method, :track_id, :gateway)
		end

		# cash → no gateway; upi → always Razorpay; card → buyer's choice (Stripe
		# default). Never trust the raw param beyond this whitelist.
		def resolved_gateway(payment_method, requested)
			case payment_method
			when "cash" then nil
			when "upi"  then "razorpay"
			when "card" then %w[stripe razorpay].include?(requested) ? requested : "stripe"
			end
		end

		def start_stripe_payment
			session = StripePayment.checkout_session(current_user, @items, @order)
			# Pending row = audit trail of the attempt; the webhook moves it to success/failed.
			@order.payments.create(status: :pending, gateway: "stripe",
			                       stripe_session_id: session.id, amount: @order.amount)
			redirect_to(session.url, allow_other_host: true, data: { turbo: false })
		rescue Stripe::StripeError
			redirect_to carts_path, alert: "Payment could not be started. Please try again."
		end

		def start_razorpay_payment
			link = RazorpayPayment.payment_link(current_user, @order)
			@order.payments.create(status: :pending, gateway: "razorpay",
			                       razorpay_payment_link_id: link.id, amount: @order.amount)
			redirect_to(link.short_url, allow_other_host: true, data: { turbo: false })
		rescue Razorpay::Error
			redirect_to carts_path, alert: "Payment could not be started. Please try again."
		end

    def generate_pdf(order)
      Prawn::Document.new do
        # text order.id, align: :center
        text "Address: #{order.id}"
        text "Email: #{order.description}"
      end.render
    end
		def create_order_items(item ,i)
			@description += helpers.description_body(item, i,@order)
			# Atomic, guarded decrement: only succeeds while stock >= quantity, so
			# concurrent orders can't drive stock negative (fixes the old
			# read-modify-write race).
			qty = item.quantity.to_i
			updated = Product.where(id: item.product_id).where("stock >= ?", qty)
			                 .update_all("stock = stock - #{qty}")
			raise OutOfStock, item.product.product_name if updated.zero?
			item.product.order_items.create(order_id: @order.id, quantity: item.quantity)
			item.destroy
		end
end