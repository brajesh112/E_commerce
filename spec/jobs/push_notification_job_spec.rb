require "rails_helper"

RSpec.describe PushNotificationJob, type: :job do
  around do |example|
    previous = ENV["FIREBASE_PROJECT_ID"]
    example.run
  ensure
    previous.nil? ? ENV.delete("FIREBASE_PROJECT_ID") : ENV["FIREBASE_PROJECT_ID"] = previous
  end

  describe "#perform" do
    before { allow(FcmPushService).to receive(:send_to_user) }

    it "does nothing for an unknown user id" do
      ENV["FIREBASE_PROJECT_ID"] = "test-proj"

      described_class.new.perform(-1, "Title", "Body")

      expect(FcmPushService).not_to have_received(:send_to_user)
    end

    it "does nothing when the user opted out (notification_status false)" do
      ENV["FIREBASE_PROJECT_ID"] = "test-proj"
      user = create(:user)
      user.update_column(:notification_status, false)

      described_class.new.perform(user.id, "Title", "Body")

      expect(FcmPushService).not_to have_received(:send_to_user)
    end

    it "does nothing when FIREBASE_PROJECT_ID is blank" do
      ENV.delete("FIREBASE_PROJECT_ID")
      user = create(:user)
      user.update_column(:notification_status, true)

      described_class.new.perform(user.id, "Title", "Body")

      expect(FcmPushService).not_to have_received(:send_to_user)
    end

    it "delegates to FcmPushService when everything is configured" do
      ENV["FIREBASE_PROJECT_ID"] = "test-proj"
      user = create(:user)
      user.update_column(:notification_status, true)

      described_class.new.perform(user.id, "Title", "Body")

      expect(FcmPushService).to have_received(:send_to_user)
        .with(user, title: "Title", body: "Body")
    end
  end
end
