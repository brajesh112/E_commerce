class HomesController < ApplicationController
	def index
		if user_signed_in? 
			if current_user.buyer? 
		   redirect_to products_path 
		  else current_user.admin?
		  	redirect_to products_path
			end 
	 else 
	  redirect_to products_path
		end 
	end
end