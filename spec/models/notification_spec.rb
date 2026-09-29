require "rails_helper"

RSpec.describe Notification, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:notificable) }
  end

  it "is polymorphic on notificable" do
    notification = create(:notification)
    expect(notification.notificable).to be_a(Product)
  end
end
