# Razorpay handles UPI (and optionally card) checkout via Payment Links.
# Keys come from the environment; see .env.example.
if ENV["RAZORPAY_KEY_ID"].present? && ENV["RAZORPAY_KEY_SECRET"].present?
  Razorpay.setup(ENV["RAZORPAY_KEY_ID"], ENV["RAZORPAY_KEY_SECRET"])
end
