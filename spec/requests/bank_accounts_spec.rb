require "rails_helper"

RSpec.describe "BankAccounts", type: :request do
  let(:user) { create(:user) }

  describe "GET /bank_accounts (index)" do
    it "returns 200 for a signed-in buyer" do
      sign_in user
      get bank_accounts_path
      expect(response).to have_http_status(:ok)
    end

    it "redirects unauthenticated users to sign in" do
      get bank_accounts_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST /bank_accounts (create)" do
    it "creates a bank account for the current user" do
      sign_in user
      expect {
        post bank_accounts_path, params: {
          bank_account: { account_no: "1234567890", ifsc_code: "HDFC0001234",
                          bank: "HDFC", branch_name: "MG Road", city: "Mumbai" }
        }
      }.to change(user.bank_accounts, :count).by(1)
      expect(response).to redirect_to(bank_accounts_path)
    end
  end

  describe "PATCH /bank_accounts/:id (update)" do
    it "updates the owner's account" do
      sign_in user
      account = create(:bank_account, user: user)
      patch bank_account_path(account), params: { bank_account: { bank: "ICICI" } }
      expect(account.reload.bank).to eq("ICICI")
      expect(response).to redirect_to(bank_accounts_path)
    end

    it "redirects with alert for another user's account (IDOR)" do
      sign_in user
      other = create(:bank_account, user: create(:user))
      patch bank_account_path(other), params: { bank_account: { bank: "ICICI" } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Account not found")
    end
  end

  describe "DELETE /bank_accounts/:id (destroy)" do
    it "destroys the owner's account" do
      sign_in user
      account = create(:bank_account, user: user)
      expect {
        delete bank_account_path(account)
      }.to change(user.bank_accounts, :count).by(-1)
      expect(response).to redirect_to(bank_accounts_path)
    end

    it "redirects with alert for another user's account (IDOR)" do
      sign_in user
      other = create(:bank_account, user: create(:user))
      delete bank_account_path(other)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Account not found")
    end
  end
end
