class OrdersController < ApplicationController
	def new
		@item = LineItem.find(params[:id])
		@order = current_user.orders.new
	end

	def create
		byebug
	end

	def edit
		byebug
		# @item = LineItem.find(params[:id])
		# @order = current_user.orders.new
		# @order.description = "Product Name:         #{@item.product.product_name}\nProduct Quantity:       #{@item.quantity}\nAmount To Pay:       #{@item.product.price* @item.quantity}"
		# @order.save
	end

	def update
		byebug
	end
end