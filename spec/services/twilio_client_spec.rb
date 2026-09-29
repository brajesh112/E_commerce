require "rails_helper"

RSpec.describe TwilioClient do
  describe ".send_message" do
    it "sends an SMS whose body is the object's action" do
      notification = create(:notification, action: "Order shipped")

      messages = double("messages")
      client = double("Twilio::REST::Client", messages: messages)
      allow(Twilio::REST::Client).to receive(:new).and_return(client)
      allow(messages).to receive(:create).and_return(double("message", sid: "SM123"))

      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("TWILIO_PHONE_NUMBER").and_return("+15005550006")

      described_class.send_message(notification)

      expect(Twilio::REST::Client).to have_received(:new)
      expect(messages).to have_received(:create) do |args|
        expect(args[:body]).to eq("Order shipped")
        expect(args[:to]).to eq("+917869309851")
        expect(args[:from]).to eq("+15005550006")
      end
    end
  end
end
