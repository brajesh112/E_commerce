require "rails_helper"

RSpec.describe NotificationJob, type: :job do
  describe "#perform" do
    it "destroys notifications older than one month and keeps recent ones" do
      old = create(:notification)
      old.update_column(:created_at, 2.months.ago)
      recent = create(:notification)

      described_class.new.perform

      expect(Notification.exists?(old.id)).to be(false)
      expect(Notification.exists?(recent.id)).to be(true)
    end
  end
end
