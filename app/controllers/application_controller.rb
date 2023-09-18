class ApplicationController < ActionController::Base
	add_flash_types :danger, :info, :warning, :success, :messages
	before_action :insert_params, only:[:create], if: :devise_controller?
	before_action :update_params, only:[:update], if: :devise_controller?
	 # protect_from_forgery

  # def access_denied(exception)
  #   redirect_to admin_dashboard_path, alert: exception.message
  # end

	  def not_found_method
	    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
	  end

		def insert_params
			devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar, :phone_number, :role, :notification_status])
		end

		def update_params
			devise_parameter_sanitizer.permit(:account_update, keys: [:name, :avatar, :phone_number, :role, :notification_status])
		end	
		
		def check
			unless user_signed_in? && (current_user.admin? || current_user.seller?)
				redirect_to root_path, alert: "Only Admin Access"
			end
		end

		def authenticate_user
			if user_signed_in?
				return redirect_to admin_dashboard_path, alert: "Login As Buyer To Accesss" if current_user.role != "buyer"
			end
		end
end
