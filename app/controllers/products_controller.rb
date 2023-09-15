class ProductsController < ApplicationController
	before_action :check, only: [:edit, :destroy, :new]
	before_action :authenticate_user
	def index
		products = params[:value].present? ? Product.includes(:category).where("categories.categories_type" => params[:value]) : Product.all
		@products = products.page params[:page] 
	end

	def show
		@product = Product.find_by(id: params[:id])
		return redirect_to root_path, alert: "Product not found" unless @product.present?
		@charges = @product.product_type.eql?("national")? 40 : "Free"
	end
end