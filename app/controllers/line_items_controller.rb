class LineItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_user
  
	def destroy
		@item = LineItem.find_by(id: params[:id])
		return redirect_to root_path, alert: "Item not found" unless @item.present?
		@item.destroy
		redirect_to carts_path
	end

	def update
		@item = LineItem.find_by(id: params[:id])
		return redirect_to carts_path, alert: "Item not found" unless @item.present?
		if @item.quantity + 1 > @item.product.stock
			flash.alert = "Product is out Of Stock"
			redirect_to carts_path
		else
			@item.update(quantity: @item.quantity + 1)
			redirect_to carts_path
		end
	end

	def edit
		@item = LineItem.find_by(id: params[:id])
		return redirect_to carts_path, alert: "Item not found" unless @item.present?
		# Never let quantity drop below 1 (it must stay > 0).
		@item.update(quantity: [@item.quantity - 1, 1].max)
		redirect_to carts_path
	end
	
end