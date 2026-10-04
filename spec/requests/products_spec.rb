require "rails_helper"

RSpec.describe "Products", type: :request do
  describe "GET /products (index)" do
    it "returns 200 without authentication" do
      create(:product)
      get products_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /products/:id (show)" do
    it "returns 200 for an existing product" do
      product = create(:product)
      get product_path(product)
      expect(response).to have_http_status(:ok)
    end

    it "redirects with alert for a missing product" do
      get product_path(0)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Product not found")
    end
  end
end
