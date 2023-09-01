class ProductsController < ApplicationController
	before_action :authenticate_user!, only: [:show]
	before_action :check, only: [:edit, :destroy, :new]
	def index
		if params[:value].present?
			product = Product.where(categories: params[:value])
		else
			product = Product.all
		end
		@product = product.paginate(page: params[:page], per_page: 5)
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
	end

	def destroy
		@product = Product.find(params[:id])
		@product.destroy
		redirect_to products_path
	end

	protected

	def product_params
		params.require(:product).permit(:product_name, :stock, :price, :categories, :description,:user_id, images:[])
	end

	def check
		unless user_signed_in? && current_user.admin?
			flash.alert = "Only Admin Access"
			redirect_to root_path
		end
	end

end