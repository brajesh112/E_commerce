class StripePayment
	class << self

		def create_customer(user)   
	  	Stripe::Customer.create(:email => user.email, :name => user.name)
	  end

	  def checkout_session(user, items)
	  	customer = Stripe::Customer.retrieve("#{user.stripe_id}")
	    Stripe::Checkout::Session.create( 
	      customer: customer, 
	      line_items: [
	      	items.map do |item|
	      		{price: item.product.price_id, quantity: item.quantity}
	      	end
	      ],
	      mode: 'payment',
	      success_url: "http://localhost:3000/payments/success?session_id={CHECKOUT_SESSION_ID}",
	      cancel_url: "http://localhost:3000/payments/cancel?session_id={CHECKOUT_SESSION_ID}"
	      )
	  end

	  def create_product(product)
	  	@product = Stripe::Product.create(name: "#{product.product_name}")
	  	Stripe::Price.create(unit_amount: (product.discount_price.to_i*100), currency: 'inr', product: @product.id)
	  end

	  def refund_payment(order)
	  	id = order.payments.find_by(status: "success").payment_id	
	  	Stripe::Refund.create({payment_intent: id,})
	  end


	  # def update_product(product)
	  # end
 	end
end