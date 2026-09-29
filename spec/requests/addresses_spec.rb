require "rails_helper"

RSpec.describe "Addresses", type: :request do
  let(:user) { create(:user) }

  describe "GET /addresses (index)" do
    it "returns 200 for a signed-in buyer" do
      sign_in user
      get addresses_path
      expect(response).to have_http_status(:ok)
    end

    it "redirects unauthenticated users to sign in" do
      get addresses_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST /addresses (create)" do
    it "creates an address for the current user" do
      sign_in user
      expect {
        post addresses_path, params: {
          address: { house_no: "12A", street: "Main Street", landmark: "Near Park",
                     pin: "110001", country: "VA" }
        }
      }.to change(user.addresses, :count).by(1)
      expect(response).to redirect_to(addresses_path)
    end
  end

  describe "PATCH /addresses/:id (update)" do
    it "updates an existing address" do
      sign_in user
      address = create(:address, user: user)
      patch address_path(address), params: { address: { street: "New Street" } }
      expect(address.reload.street).to eq("New Street")
      expect(response).to redirect_to(addresses_path)
    end

    it "redirects with alert for a missing address" do
      sign_in user
      patch address_path(0), params: { address: { street: "X" } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Address not found")
    end
  end

  describe "DELETE /addresses/:id (destroy)" do
    it "destroys an address" do
      sign_in user
      address = create(:address, user: user)
      expect {
        delete address_path(address)
      }.to change(Address, :count).by(-1)
      expect(response).to redirect_to(addresses_path)
    end
  end
end
