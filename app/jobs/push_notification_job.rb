class PushNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, title, body)
    user = User.find_by(id: user_id)
    return if user.nil?
    return if user.notification_status == false # honor opt-out
    return if ENV["FIREBASE_PROJECT_ID"].blank?  # push not configured

    FcmPushService.send_to_user(user, title: title, body: body)
  end
end
