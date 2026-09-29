require "rails_helper"

RSpec.describe DeviceToken, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { create(:device_token) }
    it { should validate_presence_of(:token) }
    it { should validate_uniqueness_of(:token) }
  end
end
