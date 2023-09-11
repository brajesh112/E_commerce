class ProductsController < ApplicationController
	before_action :check, only: [:edit, :destroy, :new]
	before_action :authenticate_user
	def index
		@product = params[:value].present? ? Product.includes(:category).where("categories.categories_type" => params[:value]) : product = Product.all
		# @product = product.paginate(page: params[:page], per_page: 5)
	end

	def new
		@product = Product.new
	end

	def create
	  @product = current_user.products.new(product_params)
		if @product.save
			redirect_to product_path(@product)
		else
			render "new"
		end
	end

	def edit
		@product = Product.find(params[:id])
	end

	def update
		@product = Product.find(params[:id])
		@product.update(product_params)
		redirect_to products_path
	end 

	def show
		@product = Product.find(params[:id])
		@charges = @product.product_type.eql?("national")? 40 : "Free"
	end

	def destroy
		@product = Product.find(params[:id])
		@product.destroy
		redirect_to products_path
	end

	protected

	def product_params
		params.require(:product).permit(:product_name, :stock, :price, :category_id, :description,:user_id, images:[])
	end
end