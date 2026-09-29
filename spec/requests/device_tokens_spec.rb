require "rails_helper"

RSpec.describe "DeviceTokens", type: :request do
  let(:user) { create(:user) }

  describe "POST /device_tokens" do
    it "creates a token for the current user and returns 200" do
      sign_in user
      expect {
        post device_tokens_path, params: { token: "fcm-abc", platform: "web" }
      }.to change(user.device_tokens, :count).by(1)
      expect(response).to have_http_status(:ok)
    end

    it "returns 400 when the token is blank" do
      sign_in user
      post device_tokens_path, params: { token: "" }
      expect(response).to have_http_status(:bad_request)
    end

    it "re-owns an existing token to the current user" do
      original_owner = create(:user)
      token = create(:device_token, user: original_owner, token: "shared-token")

      sign_in user
      post device_tokens_path, params: { token: "shared-token" }
      expect(response).to have_http_status(:ok)
      expect(token.reload.user).to eq(user)
    end

    it "redirects unauthenticated requests to sign in" do
      post device_tokens_path, params: { token: "fcm-abc" }
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
