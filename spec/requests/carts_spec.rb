require "rails_helper"

RSpec.describe "Carts", type: :request do
  let(:user) { create(:user) }

  describe "GET /carts (index)" do
    it "returns 200 for a signed-in buyer" do
      sign_in user
      get carts_path
      expect(response).to have_http_status(:ok)
    end

    it "redirects unauthenticated users to sign in" do
      get carts_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects a non-buyer (seller) to the admin dashboard" do
      sign_in create(:user, :seller)
      get carts_path
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET /carts/new" do
    it "adds a product to the cart and redirects to products" do
      sign_in user
      product = create(:product)
      expect {
        get new_cart_path, params: { id: product.id }
      }.to change(user.cart.line_items, :count).by(1)
      expect(response).to redirect_to(products_path)
    end
  end
end
