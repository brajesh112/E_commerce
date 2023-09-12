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
		@product = Product.find_by(id: params[:id])
		return redirect_to root_path, alert: "Product not found" unless @product.present?
	end

	def update
		@product = Product.find_by(id: params[:id])
		return redirect_to root_path, alert: "Product not found" unless @product.present?
		@product.update(product_params)
		redirect_to products_path
	end 

	def show
		@product = Product.find_by(id: params[:id])
		return redirect_to root_path, alert: "Product not found" unless @product.present?
		@charges = @product.product_type.eql?("national")? 40 : "Free"
	end

	def destroy
		@product = Product.find_by(id: params[:id])
		return redirect_to root_path, alert: "Product not found" unless @product.present?
		@product.destroy
		redirect_to products_path
	end

	protected

	def product_params
		params.require(:product).permit(:product_name, :stock, :price, :category_id, :description,:user_id, images:[])
	end
end