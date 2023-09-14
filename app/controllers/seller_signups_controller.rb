class SellerSignupsController < ApplicationController
	
	def index
		@account = params
		@account.permit!
	end
end