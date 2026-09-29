class SellerSignupsController < ApplicationController
	
	def index
		@account = params.permit(:account_no, :ifsc_code, :bank, :branch_name, :city)
	end
end