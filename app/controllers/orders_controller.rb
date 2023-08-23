class OrdersController < ApplicationController
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
		@order.status = "order_placed"
		s = ""
		i = 1 
		@order.product.each do |product|
			s+= "#{i}. Product Name: #{product.product_name}, Product Quantity: #{}" 
			@order.description = ""
		track = rand 100000..999999
		@order.track_id = "TRC#{track}"
		@order.save
		if product_id.class == array
			current_user.cart.line_items.destroy_all
		else
			LineItem.find(params[:order][:item_id]).destroy
		end
		redirect_to orders_path
	end

	def index
		@orders = current_user.orders.all
	end

	def edit
		byebug
	end

	def update
		byebug
	end


	def order_params
		if params[:order][:product_id].present?
			params[:order][:product_id] = current_user.cart.line_items.pluck(:product_id)
		end
		params.require(:order).permit(:product_id, :address_id, :payment_method)
	end
end