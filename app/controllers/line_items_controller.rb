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
		x = @item.quantity
		if  x+1 > @item.product.stock
			flash.alert = "Product is out Of Stock"
			redirect_to carts_path
		else
			@item.update(quantity:"#{x+1}")
			redirect_to carts_path
		end
	end

	def edit
		@item = LineItem.find_by(id: params[:id])
		x = @item.quantity
		@item.update(quantity:"#{x-1}")
		redirect_to carts_path
	end
	
end