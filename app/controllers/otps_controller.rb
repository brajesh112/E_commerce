class OtpsController < ApplicationController
	
	def new
		@user = User.find_by(email: params[:email])
		value = rand 1000..9999
		@user.otps.create(onetp: value)
		respond_to do |format|
      OtpMailer.with(user: @user).otp_email.deliver
      render partial: "partials_/otp_submition"
      return redirect_to admin_dashboard_path 
    end
	end
end