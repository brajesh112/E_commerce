class ProductsController < ApplicationController
	before_action :check, only: [:edit, :destroy, :new]
	before_action :authenticate_user
	def index
		@product = params[:value].present? ? Product.includes(:category).where("categories.categories_type" => params[:value]) : product = Product.all
		# @product = product.paginate(page: params[:page], per_page: 5)
	end

	def show
		@product = Product.find_by(id: params[:id])
		return redirect_to root_path, alert: "Product not found" unless @product.present?
		@charges = @product.product_type.eql?("national")? 40 : "Free"
	end
end