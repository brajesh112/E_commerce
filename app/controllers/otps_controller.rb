class OtpsController < ApplicationController
	OTP_TTL = 10.minutes
	MAX_ATTEMPTS = 5

	def new
	end

	def create
		@user = User.find_by(email: params[:email])
		return redirect_to root_path unless @user.present?
		@user.otps.create(onetp: rand(100000..999999))
		session[:otp_attempts] = 0
		OtpMailer.with(user: @user).otp_email.deliver
		redirect_to edit_otp_path(@user)
	end

	def index
		@user = User.find_by(id: params[:user])
		return redirect_to root_path unless @user.present?
		return redirect_to root_path, alert: "Too many attempts. Request a new code." if too_many_attempts?

		otp = @user.otps.order(:created_at).last
		if valid_otp?(otp, params[:query])
			session.delete(:otp_attempts)
			otp.destroy # single use — prevent replay
			return redirect_to new_user_session_path(value: params[:query])
		end

		session[:otp_attempts] = session[:otp_attempts].to_i + 1
		redirect_to edit_otp_path(@user), alert: "Invalid or expired code."
	end

	def edit
		@user = User.find_by(id: params[:id])
	end

	private

	def too_many_attempts?
		session[:otp_attempts].to_i >= MAX_ATTEMPTS
	end

	def valid_otp?(otp, query)
		return false if otp.nil? || query.blank?
		return false if otp.created_at < OTP_TTL.ago
		ActiveSupport::SecurityUtils.secure_compare(otp.onetp.to_s, query.to_s)
	end
end
