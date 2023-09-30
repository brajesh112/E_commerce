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
	        # price: 'price_1NvZegSBU8NpHWncKDTQb3OT', #price api id usually starts with price_ApIiD
	        # quantity: 1,
	      ],
	      mode: 'payment',
	      success_url: "http://localhost:3000/payments/success",
	      cancel_url: "http://localhost:3000/payments/cancel"
	      )
	  end

	  def create_product(product)
	  	@product = Stripe::Product.create(name: "#{product.product_name}")
	  	Stripe::Price.create(unit_amount: (product.discount_price.to_i*100), currency: 'inr', product: @product.id)
	  end

	  # def update_product(product)
	  # end
 	end
end