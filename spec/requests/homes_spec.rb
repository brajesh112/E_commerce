require "rails_helper"

RSpec.describe "Homes", type: :request do
  describe "GET / (index)" do
    it "redirects to products_path" do
      get root_path
      expect(response).to redirect_to(products_path)
    end
  end
end
