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
		 track = rand 100000..999999
		 @track = "TRC#{track}"
		 @status = "pending"
		 @order = current_user.orders.new
	end

	def create
		@items = LineItem.where(id: params[:order][:item_id].split)
		@order = current_user.orders.new (order_params)
		i = 1 
		@order.description = ""
		@products = []
		@items.all.map { |item| @products << item.product }
		@order.products << @products
		return redirect_to new_order_path, alert: "something went wrong" unless @order.save
		byebug
		@description = ""
		@items.each do |item|
			create_order_items(item, i)
			helpers.create_transactions(item, @order)
			i +=1
		end
		@order.update(description: @description)
		helpers.add_notification(@order, "Your Order Is Placed")
		session = StripePayment.checkout_session(current_user, @items)
		# byebug
		redirect_to(session.url , :allow_other_host=> true, data: {turbo: false})
		# byebug
		# redirect_to order_path(@order)
	end

	def show
		@order = Order.find_by(id: params[:id])
		return redirect_to root_path, alert: "Order not found" unless @order.present?
	end

	def index
		orders = current_user.orders.all
		redirect_to root_path, alert: "You have not ordered anything at" unless orders.present?
		@orders = orders.page params[:page]
	end

	def update
		@order = Order.find_by(id: params[:id])
		return redirect_to root_path unless @order.present?
		@order.update(status: "cancel", track_id: nil)
		helpers.add_notification(@order, "Your Order Is Canceled")
		@order.shipment.destroy
		redirect_to orders_path
	end

	private

		def order_params
			params.require(:order).permit(:address_id, :payment_method, :track_id, :status)
		end

		def create_order_items(item ,i)
			@description += helpers.description_body(item, i,@order)
			item.product.stock -= item.quantity
			item.product.update(stock: item.product.stock)
			item.destroy
		end 
end