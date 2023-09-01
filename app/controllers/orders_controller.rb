class OrdersController < ApplicationController
	before_action :check, only: [:edit, :destroy]
	before_action :authenticate_user!
	def new
		@item = params[:id]
		@id = @item
		if @item.to_i !=0
			@quantity = LineItem.find(@item).quantity
			@product = LineItem.find(@item).product
		end
		@cart = current_user.cart
		@address = current_user.addresses
		@order = current_user.orders.new
	end

	def create
		@order = current_user.orders.new (order_params)
		@order.status = "pending"
		i = 1 
		@order.description = ""
		track = rand 100000..999999
		@order.track_id = "TRC#{track}"
		@order.save
		@description = ""
		if @order.product_ids.size >1
			current_user.cart.line_items.each do |item|
				@description += "<div class= 'row'><div class='col-auto'><b>#{i}.</b></div> <div class='col-auto'><b>Product Name:</b> #{item.product.product_name},</div></div><div class='row'><div class= 'col-auto'><b>Product Quantity:</b> #{item.quantity},</div><div class='col-auto'><b>Total Price:</b> ₹#{item.product.price * item.quantity}</div></div>"
				 	i +=1;
				item.product.stock -= item.quantity
				item.product.update(stock: item.product.stock)
				item.destroy
			end
		else
			item = LineItem.find(params[:order][:item_id])
					@description += "<div class= 'row'><div class='col-auto'><b>#{i}.</b></div> <div class='col-auto'><b>Product Name:</b> #{item.product.product_name},</div></div><div class='row'><div class= 'col-auto'><b>Product Quantity:</b> #{item.quantity},</div><div class='col-auto'><b>Total Price:</b> ₹#{item.product.price * item.quantity}</div></div>"
			item.product.stock -= item.quantity
			item.product.update(stock: item.product.stock)
			item.destroy
		end
		@order.update(description: @description)
		redirect_to order_path(@order)
	end

	def show
		@order = Order.find(params[:id])
	end

	def index
		if current_user.admin?
			orders = Order.all
		else
			orders = current_user.orders.all
		end
		unless orders.present?
			flash.alert = "You have not ordered anything at"
			redirect_to root_path
		end
		@orders = orders.paginate(page: params[:page], per_page: 1)
	end

	def edit
		@order = Order.find(params[:id])
	end

	def update
		@order = Order.find(params[:id])
		@order.update(status: params[:order][:status])
		redirect_to orders_path
	end


	def order_params
		if params[:order][:product_ids].present?
			a = Array.new 
			a << params[:order][:product_ids].to_i
			params[:order][:product_ids] = a
		else
			params[:order][:product_ids] = current_user.cart.line_items.pluck(:product_id)
		end
		params.require(:order).permit(:address_id, :payment_method, product_ids:[])
	end

	def check
		unless user_signed_in? && current_user.admin?
			flash.alert = "Only Admin Access"
			redirect_to root_path
		end
	end
end