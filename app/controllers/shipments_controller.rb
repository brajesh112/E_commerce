class ShipmentsController < ApplicationController
	before_action :check, only: [:edit, :destroy]
	before_action :authenticate_user!
	before_action :authenticate_user
	def index
		if current_user.admin?
			@orders = Order.all
		else
			@orders = current_user.orders.all
		end
	end

	def edit
		@shipment = Shipment.find(params[:id])
	end

	def update
		@shipment = Shipment.find(params[:id])
		@shipment.update(status: params[:shipment][:status], expected_delivery: params[:shipment][:expected_delivery])
		redirect_to shipments_path
	end

	def destroy
		@shipment = Shipment.find(param[:id])
		@shipment.destroy
	end 

	def show
		@shipment = Shipment.find(params[:id])
	end
end