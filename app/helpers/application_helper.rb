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

	def delivery_date
		DateTime.current.to_date + 7.days 
	end

	def add_notification (obj,action)
		@notification = obj.notifications.new(user_id: obj.user.id, action: action)
		@notification.save
		
	end
end