require "rails_helper"

RSpec.describe OtpJob, type: :job do
  describe "#perform" do
    it "destroys otps older than one day and keeps recent ones" do
      old = create(:otp)
      old.update_column(:created_at, 2.days.ago)
      recent = create(:otp)

      described_class.new.perform

      expect(Otp.exists?(old.id)).to be(false)
      expect(Otp.exists?(recent.id)).to be(true)
    end
  end
end
