# frozen_string_literal: true

class Sessions::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    @email = params[:user][:email]
    @user = User.find_by(email: @email)
    # if @user.role != "buyer"
    #   sign_in(resource_name, resource)
    #   return redirect_to new_otp_path(email: @email)
    # end
   
    super
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
