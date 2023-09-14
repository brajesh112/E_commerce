# frozen_string_literal: true

class Sessions::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    @onepass = params[:value].present? ? params[:value] : nil 
    super
  end

  # POST /resource/sign_in
  def create
    @user = User.find_by(email: params[:user][:email])
    return redirect_to root_path unless @user.present?
    if @user.role.eql?("admin") || (@user.role.eql?("seller") && params[:user][:onepass].present?)
     self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)
     return redirect_to admin_dashboard_path
    elsif @user.role.eql?("seller")
     return redirect_to root_path, alert: "Please Verify first"
    end
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
