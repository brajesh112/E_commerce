class TrackingOrdersController < ApplicationController
	
	def new
	end
		
	def update
	end


	def track_params
		params.require(:tracking_order).permit(:status, :place, :shipment_id)
	end
end
