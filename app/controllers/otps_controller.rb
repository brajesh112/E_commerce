class OtpsController < ApplicationController
	
	def new
	end

	def create
		@user = User.find_by(email: params[:email])
		return redirect_to root_path unless @user.present?
		value = rand 1000..9999
		@user.otps.create(onetp: value)
		OtpMailer.with(user: @user).otp_email.deliver
		return redirect_to edit_otp_path(@user)
	end  
	
	def index
		@user = User.find_by(id: params[:user])
		if @user.otps.last.onetp.eql?(params[:query].to_i)
			
			return redirect_to new_user_session_path(value: params[:query])
		end
		return redirect_to edit_otp_path(@user)
	end

	def edit
		@user = User.find_by(id: params[:id])
	end

end