class ProductsController < ApplicationController
	# before_action :authenticate, only: [:new]
	before_action :authenticate_user!, only: [:new, :show]
	def index
		@product = Product.all 
	end
	def new
		@product = Product.new
	end

	def create
		byebug
	  @product = current_user.products.new(product_params)
		if @product.save
			redirect_to product_path(@product)
		else
			render "new"
		end
	end

	def show
		@product = Product.find(params[:id])
	end

	def search
		byebug
	end

	protected
	def product_params
		params.require(:product).permit(:product_name, :stock, :price, :description,:user_id, images:[])
	end

	def authenticate
		unless user_signed_in?
			redirect_to new_user_session_path
		end
	end
end