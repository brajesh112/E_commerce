class LineItemsController < ApplicationController

	def destroy
		@item = LineItem.find(params[:id])
		@item.destroy
		redirect_to carts_path
	end

	def update
		@item = LineItem.find(params[:id])
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
		@item = LineItem.find(params[:id])
		x = @item.quantity
		@item.update(quantity:"#{x-1}")
		redirect_to carts_path
	end
	
end