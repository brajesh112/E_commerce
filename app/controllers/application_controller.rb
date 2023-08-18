class ApplicationController < ActionController::Base
	before_action :insert_params, only:[:create, :update]

	def insert_params
		devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar, :phone_number, :image])
	end
end
