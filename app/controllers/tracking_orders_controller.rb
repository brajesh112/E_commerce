class TrackingOrdersController < ApplicationController
	before_action :check, only: [:edit, :destroy]
	before_action :authenticate_user!
	def show
		if params[:query].present?
			@shipment = Order.find_by(track_id: params[:query]).shipment
		else
			@shipment = Shipment.find(params[:id])
		end
	end

	def new
		@shipment = Shipment.find(params[:id]) 
		@track = @shipment.tracking_orders.new
	end

	def create
		@shipment = Shipment.find(params[:tracking_order][:shipment_id])
		@shipment.tracking_orders.create(status: @shipment.status, place: params[:tracking_order][:place])
		redirect_to tracking_order_path(@shipment)
	end

	def check
		unless user_signed_in? && current_user.admin?
			flash.alert = "Only Admin Access"
			redirect_to root_path
		end
	end

end
