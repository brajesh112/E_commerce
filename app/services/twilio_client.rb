class TwilioClient
	class << self
		def send_message(obj)
	   phone = obj.user&.phone_number
	   return if phone.blank?
	   client = Twilio::REST::Client.new
	   @message = client.messages.create(from: ENV['TWILIO_PHONE_NUMBER'], to: "+91#{phone}", body: "#{obj.action}")
	 end
	end
end