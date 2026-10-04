require "rails_helper"

RSpec.describe "Otps", type: :request do
  let(:user) { create(:user) }

  describe "POST /otps (create)" do
    it "creates an OTP, sends the mail and redirects to edit for a known email" do
      expect {
        post otps_path, params: { email: user.email }
      }.to change(user.otps, :count).by(1)
      expect(response).to redirect_to(edit_otp_path(user))
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end

    it "redirects to root for an unknown email" do
      post otps_path, params: { email: "nobody@example.com" }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /otps (index - verify)" do
    it "redirects to sign in and destroys the OTP on a matching code" do
      otp = create(:otp, user: user, onetp: 123456)
      get otps_path, params: { user: user.id, query: "123456" }
      expect(response).to redirect_to(new_user_session_path(value: "123456"))
      expect(Otp.exists?(otp.id)).to be(false)
    end

    it "redirects to edit with an alert on a wrong code" do
      create(:otp, user: user, onetp: 123456)
      get otps_path, params: { user: user.id, query: "000000" }
      expect(response).to redirect_to(edit_otp_path(user))
      expect(flash[:alert]).to be_present
    end

    it "treats an expired OTP (created > 10 min ago) as invalid" do
      otp = create(:otp, user: user, onetp: 123456, created_at: 11.minutes.ago)
      get otps_path, params: { user: user.id, query: "123456" }
      expect(response).to redirect_to(edit_otp_path(user))
      expect(Otp.exists?(otp.id)).to be(true) # not consumed
    end

    it "locks out after 5 failed attempts" do
      create(:otp, user: user, onetp: 123456)
      5.times { get otps_path, params: { user: user.id, query: "000000" } }
      get otps_path, params: { user: user.id, query: "123456" }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to match(/Too many attempts/)
    end

    it "redirects to root for an unknown user" do
      get otps_path, params: { user: 0, query: "123456" }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /otps/:id/edit" do
    it "returns 200" do
      get edit_otp_path(user)
      expect(response).to have_http_status(:ok)
    end
  end
end
