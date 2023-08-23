class CartsController < ApplicationController
	before_action :authenticate_user!
	
	def index
		@items = current_user.cart.line_items.all
	end

	def show
		@product = params[:id]
		if current_user.cart.line_items.where(product_id: @product).pluck(:product_id).present?
			flash.alert = "Product is all ready in cart"
		 redirect_to products_path
		else	
			current_user.cart.line_items.create(quantity: 1, product_id: @product)
			redirect_to products_path
		end
	end
end