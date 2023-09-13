class NotificationJob < ActiveJob::Base
  queue_as :default

  def perform
    @notifications = Notification.where("created_at < ?", (DateTime.now - 1.month).utc)
    @notifications.destroy_all
  end
end