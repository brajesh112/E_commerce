class Notification < ApplicationRecord
	belongs_to :user
	belongs_to :notificable, polymorphic: true
	after_create :use_twilio

	def use_twilio
		TwilioClient.send_message(self)
	end
end

