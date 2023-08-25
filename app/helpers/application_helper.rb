module ApplicationHelper

	def add_class(val)
		if Shipment.statuses.count - 1 == val
			"text-end"
		else
			"text-center"
		end
	end

	def add_place (obj,key)
		if obj.tracking_orders.where(status: key).present?
			obj.tracking_orders.where(status: key).last.place
		end
	end

end