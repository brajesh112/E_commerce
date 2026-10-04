require "rails_helper"

RSpec.describe "Push", type: :request do
  describe "GET /firebase-messaging-sw.js (service_worker)" do
    it "returns 200 with a JavaScript content type, no auth required" do
      get "/firebase-messaging-sw.js"
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/javascript")
    end
  end
end
