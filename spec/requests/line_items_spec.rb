require "rails_helper"

RSpec.describe "LineItems", type: :request do
  let(:user) { create(:user) }

  describe "DELETE /line_items/:id (destroy)" do
    it "removes the item and redirects to the cart" do
      sign_in user
      item = create(:line_item, cart: user.cart, product: create(:product))
      expect {
        delete line_item_path(item)
      }.to change(user.cart.line_items, :count).by(-1)
      expect(response).to redirect_to(carts_path)
    end

    it "redirects with alert for a missing item" do
      sign_in user
      delete line_item_path(0)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Item not found")
    end
  end

  describe "PATCH /line_items/:id (update - increment)" do
    it "increments quantity when stock allows" do
      sign_in user
      product = create(:product, stock: 10)
      item = create(:line_item, cart: user.cart, product: product, quantity: 1)
      patch line_item_path(item)
      expect(item.reload.quantity).to eq(2)
      expect(response).to redirect_to(carts_path)
    end
  end

  describe "GET /line_items/:id/edit (decrement)" do
    it "decrements quantity and redirects to the cart" do
      sign_in user
      product = create(:product, stock: 10)
      item = create(:line_item, cart: user.cart, product: product, quantity: 3)
      get edit_line_item_path(item)
      expect(item.reload.quantity).to eq(2)
      expect(response).to redirect_to(carts_path)
    end
  end

  describe "auth" do
    it "redirects unauthenticated users to sign in" do
      item = create(:line_item, product: create(:product))
      delete line_item_path(item)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
