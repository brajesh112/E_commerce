require "rails_helper"

RSpec.describe StripeEvent, type: :model do
  describe "validations" do
    subject { StripeEvent.create!(event_id: "evt_1", event_type: "checkout.session.completed") }
    it { should validate_presence_of(:event_id) }
    it { should validate_uniqueness_of(:event_id) }
  end
end
