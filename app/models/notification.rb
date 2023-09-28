class Notification < ApplicationRecord
	belongs_to :user
	belongs_to :notificable, polymorphic: true
	after_create :send_message

 def send_message
   client = Twilio::REST::Client.new
   @message = client.messages.create(
                            from: ENV['TWILIO_PHONE_NUMBER'],
                            to: '+917869309851',
                            body: 'This is a message for verification'
                          )
 end
end

