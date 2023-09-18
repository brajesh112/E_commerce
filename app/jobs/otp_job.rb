class OtpJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @otps = Otp.where("created_at < ?", (DateTime.now - 1.day).utc)
    @otps.destroy_all
  end
end
