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
		# Mirror the in-app notification as a Firebase push (async).
		PushNotificationJob.perform_later(obj.user.id, "E Commerce", action) if @notification.persisted?
	end

	def firebase_web_config
		{
			apiKey: ENV["FIREBASE_API_KEY"],
			authDomain: ENV["FIREBASE_AUTH_DOMAIN"],
			projectId: ENV["FIREBASE_PROJECT_ID"],
			messagingSenderId: ENV["FIREBASE_MESSAGING_SENDER_ID"],
			appId: ENV["FIREBASE_APP_ID"]
		}
	end

	def firebase_push_enabled?
		ENV["FIREBASE_API_KEY"].present? && ENV["FIREBASE_VAPID_KEY"].present?
	end

	def order_status(order)
		order.status.eql?("cancel") || order.status.eql?("refunded")
	end

	def failed_payment(order)
		order.payment_method.eql?("card") && (order.status.eql?("pending") || order.status.eql?("payment_failed"))
	end
end