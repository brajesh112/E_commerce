class ShipmentsController < ApplicationController
	before_action :check, only: [:edit, :destroy]
	before_action :authenticate_user!
	before_action :authenticate_user

	def index
		@orders = current_user.orders.where("status != ?", 2)
	end
	
	def show
		@shipment = Shipment.find_by(id: params[:id])
		return redirect_to root_path, alert: "Shipment not found" unless @shipment.present?
	end
end