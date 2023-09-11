class TrackingOrdersController < ApplicationController
	before_action :check, only: [:edit, :destroy, :new]
	before_action :authenticate_user

	def show
		@shipment = Order.find_by(track_id: params[:query]).present? ?
			 Order.find_by(track_id: params[:query]).shipment : Shipment.find_by(id: params[:id])
		redirect_to root_path, alert: "Please insert valid Id" if @shipment.nil?
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
	
end
