class ApplicationController < ActionController::Base
	add_flash_types :danger, :info, :warning, :success, :messages
	before_action :insert_params, only:[:create], if: :devise_controller?
	before_action :update_params, only:[:update], if: :devise_controller?
	def insert_params
		devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar, :phone_number, :role])
	end

	def update_params
		devise_parameter_sanitizer.permit(:account_update, keys: [:name, :avatar, :phone_number, :role])
	end	
end
