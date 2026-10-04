class DeviceTokensController < ApplicationController
  before_action :authenticate_user!

  # POST /device_tokens  { token:, platform? }
  # Registers (or re-owns) an FCM token for the current user.
  def create
    token = params[:token].to_s
    return head :bad_request if token.blank?

    device_token = DeviceToken.find_or_initialize_by(token: token)
    device_token.user = current_user
    device_token.platform = params[:platform].presence || "web"
    device_token.save!
    head :ok
  end
end
