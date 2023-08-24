class ShipmentsController < ApplicationController
	before_action :check, only: [:edit, :destroy]
	def index
		if current_user.admin?
			@orders = Orders.all
		else
			@orders = current_user.orders.all
		end
	end

	def edit
		@shipment = Shipment.find(params[:id])
	end

	def update
		@shipment = Shipment.find(params[:id])
		@shipment.update(status: params[:shipment][:status])
		redirect_to shipments_path
	end

	def destroy
		@shipment = Shipment.find(param[:id])
		@shipment.destroy
	end 

	def show
		@shipment = Shipment.find(params[:id])
	end
	
	def check
		unless user_signed_in? && current_user.admin?
			flash.alert = "Only Admin Access"
			redirect_to root_path
		end
	end

end