class AddressesController < ApplicationController
	before_action :authenticate_user!
	def index
		@address = Address.all
	end

	def new
		@address = Address.new
	end

	def create
		@address = current_user.addresses.new(address_params)
		@address.save
		redirect_to addresses_path
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