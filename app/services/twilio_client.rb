class TwilioClient
	class << self
		def send_message(obj)
	   client = Twilio::REST::Client.new
	   @message = client.messages.create(from: ENV['TWILIO_PHONE_NUMBER'],to: '+917869309851',body: "#{obj.action}")
	 end
	end
end