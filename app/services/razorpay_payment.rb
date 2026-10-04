class RazorpayPayment
	class << self
		# Create a hosted Razorpay Payment Link for an order. The buyer is
		# redirected to link.short_url; the webhook confirms payment. Mirrors
		# StripePayment.checkout_session.
		def payment_link(user, order)
			host = ENV.fetch("APP_HOST", "http://localhost:3000")
			Razorpay::PaymentLink.create(
				amount: (order.amount.to_d * 100).to_i, # paise
				currency: "INR",
				accept_partial: false,
				reference_id: order.id.to_s,
				description: "Order ##{order.id}",
				customer: { name: user.name, email: user.email, contact: user.phone_number },
				notify: { sms: false, email: false },
				callback_url: "#{host}/payments/razorpay_return",
				callback_method: "get"
			)
		end

		# Refund the captured payment for an order. The refund.processed webhook
		# confirms it. Mirrors StripePayment.refund_payment.
		def refund_payment(order)
			payment = order.payments.find_by(status: "success", gateway: "razorpay")
			return if payment.nil? || payment.payment_id.blank?
			Razorpay::Payment.fetch(payment.payment_id).refund
		end
	end
end
