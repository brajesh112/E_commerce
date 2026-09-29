require "rails_helper"

RSpec.describe FcmPushService do
  describe ".send_to_user" do
    it "sends a message for each of the user's device tokens" do
      user = create(:user)
      create(:device_token, user: user, token: "tok-a")
      create(:device_token, user: user, token: "tok-b")

      allow(described_class).to receive(:send_message)

      described_class.send_to_user(user, title: "Hi", body: "There", data: { k: "v" })

      expect(described_class).to have_received(:send_message).with("tok-a", "Hi", "There", { k: "v" })
      expect(described_class).to have_received(:send_message).with("tok-b", "Hi", "There", { k: "v" })
      expect(described_class).to have_received(:send_message).twice
    end

    it "does nothing when the user has no device tokens" do
      user = create(:user)
      allow(described_class).to receive(:send_message)

      described_class.send_to_user(user, title: "Hi", body: "There")

      expect(described_class).not_to have_received(:send_message)
    end

    it "returns nil for a nil user" do
      allow(described_class).to receive(:send_message)

      expect(described_class.send_to_user(nil, title: "Hi", body: "There")).to be_nil
      expect(described_class).not_to have_received(:send_message)
    end
  end

  describe ".send_message" do
    around do |example|
      previous = {
        "FIREBASE_PROJECT_ID" => ENV["FIREBASE_PROJECT_ID"],
        "FIREBASE_CREDENTIALS_JSON" => ENV["FIREBASE_CREDENTIALS_JSON"]
      }
      ENV["FIREBASE_PROJECT_ID"] = "test-proj"
      ENV["FIREBASE_CREDENTIALS_JSON"] =
        '{"type":"service_account","project_id":"test-proj","private_key_id":"x",' \
        '"private_key":"-----BEGIN PRIVATE KEY-----\nx\n-----END PRIVATE KEY-----\n",' \
        '"client_email":"svc@test-proj.iam.gserviceaccount.com","client_id":"1",' \
        '"token_uri":"https://oauth2.googleapis.com/token"}'
      example.run
    ensure
      previous.each { |k, v| v.nil? ? ENV.delete(k) : ENV[k] = v }
    end

    before do
      authorizer = double("authorizer", fetch_access_token!: { "access_token" => "tok" })
      allow(Google::Auth::ServiceAccountCredentials)
        .to receive(:make_creds).and_return(authorizer)
    end

    it "posts to the correct FCM v1 URL with a Bearer token" do
      stub = stub_request(:post, "https://fcm.googleapis.com/v1/projects/test-proj/messages:send")
             .with(headers: { "Authorization" => "Bearer tok" })
             .to_return(status: 200, body: "{}")

      response = described_class.send_message("tok-1", "Title", "Body", { foo: 1 })

      expect(stub).to have_been_requested
      expect(response.code.to_i).to eq(200)
    end

    it "prunes a matching DeviceToken when FCM responds 404" do
      user = create(:user)
      create(:device_token, user: user, token: "dead-token")

      stub_request(:post, "https://fcm.googleapis.com/v1/projects/test-proj/messages:send")
        .to_return(status: 404, body: '{"error":"NOT_FOUND"}')

      described_class.send_message("dead-token", "Title", "Body")

      expect(DeviceToken.where(token: "dead-token")).to be_empty
    end

    it "rescues a network error, returns nil, and keeps the token" do
      user = create(:user)
      create(:device_token, user: user, token: "live-token")

      stub_request(:post, "https://fcm.googleapis.com/v1/projects/test-proj/messages:send")
        .to_raise(SocketError.new("boom"))

      result = described_class.send_message("live-token", "Title", "Body")

      expect(result).to be_nil
      expect(DeviceToken.where(token: "live-token")).to exist
    end
  end
end
