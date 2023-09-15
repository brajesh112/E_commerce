class TrackingOrdersController < ApplicationController
	before_action :check, only: [:edit, :destroy, :new]
	before_action :authenticate_user

	def show
		@shipment = Order.find_by(track_id: params[:query]).present? ?
			 Order.find_by(track_id: params[:query]).shipment : Shipment.find_by(id: params[:id])
		redirect_to root_path, alert: "Please insert valid Id" if @shipment.nil?
	end
end
