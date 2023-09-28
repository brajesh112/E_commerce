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


	def create_transactions(item, order)
		@price = item.product.discount_price * item.quantity
		@admin_comision = (item.product.category.category_comission * @price)/100 
		@tax = @price/50
		@seller_earnings = @price - (@admin_comision + @tax)
		item.product.user.transactions.create(admin_commision: @admin_comision, tax: @tax, seller_earning: @seller_earnings, total_amount: @price, product_id: item.product.id, order_id: order.id)
	end
end