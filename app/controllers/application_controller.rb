class ApplicationController < ActionController::Base
	add_flash_types :danger, :info, :warning, :success, :messages
	before_action :insert_params, only:[:create], if: :devise_controller?
	before_action :update_params, only:[:update], if: :devise_controller?

	# rescue_from ActionController::RoutingError, with: :route_not_found
	# rescue_from ActionController::ActionNotFound, with: :action_not_found

	def insert_params
		devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar, :phone_number, :role])
	end

	def update_params
		devise_parameter_sanitizer.permit(:account_update, keys: [:name, :avatar, :phone_number, :role])
	end	
	def check
		unless user_signed_in? && current_user.admin?
			redirect_to root_path, alert: "Only Admin Access"
		end
	end

	def authenticate_user
		if user_signed_in?
			return redirect_to admin_dashboard_path if current_user.role != "buyer"
		end
	end

	# def routing_error(error = 'Routing error', status = :not_found, exception=nil)
	# 	render_exception(404, "Routing Error", exception)
	# end

	# def action_missing(m, *args, &block)
	#   Rails.logger.error(m)
	#   redirect_to '/*path'
	# end
end
