class AddressesController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_user
	def index
		@address = current_user.addresses.all
	end

	def new
		@param = params[:id]
		@address = Address.new
	end

	def create
		@address = current_user.addresses.new(address_params)
		@address.save
		if params[:address][:order_id].present?
			redirect_to new_order_path
		else
			redirect_to addresses_path
		end
	end

	def destroy
		@address = Address.find(params[:id])
		@address.destroy
		redirect_to addresses_path
	end

	def edit
		@address = Address.find(params[:id])
	end

	def update
		@address = Address.find(params[:id])
		@address.update(address_params)
		redirect_to addresses_path
	end

	def address_params
		params.require(:address).permit(:house_no, :street, :landmark, :city, :state, :pin, :state, :country)
	end

end