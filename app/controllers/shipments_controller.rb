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
	
	def show
		@shipment = Shipment.find_by(id: params[:id])
		return redirect_to root_path, alert: "Shipment not found" unless @shipment.present?
	end
end