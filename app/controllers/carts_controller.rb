class CartsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_user
	def index
		@items = current_user.cart.line_items.all
	end

	def show
		@product = params[:id]
		current_user.cart.line_items.create(quantity: 1, product_id: @product)
		# return redirect_to new_notification_path(title: "Cart- Item", description: "Added To Cart")
		redirect_to products_path
	end
end