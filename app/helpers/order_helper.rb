module OrderHelper
	def description_body(item, i,order)
		"<div class= 'row'><div class='col-auto'><b>#{i}.</b></div> <div class='col-auto'><b>Product Name:</b> #{item.product.product_name},</div></div><div class='row'><div class= 'col-auto'><b>Product Quantity:</b> #{item.quantity},</div><div class='col-auto'><b>Total Price:</b> #{item.product.discount_price}</div></div>"
	end
end
