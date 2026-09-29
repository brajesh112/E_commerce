require "rails_helper"

RSpec.describe "Notifications", type: :request do
  let(:user) { create(:user) }

  describe "GET /notifications (index)" do
    it "returns 200 for a signed-in buyer" do
      sign_in user
      get notifications_path
      expect(response).to have_http_status(:ok)
    end

    it "redirects unauthenticated users to sign in" do
      get notifications_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
