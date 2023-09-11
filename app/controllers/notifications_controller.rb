class NotificationsController < ApplicationController
	before_action :authenticate_user
	before_action :authenticate_user!
	def index
		@notifications = Notification.all
	end

	def show
		@notification = Notification.find_by(id: params[:id])
	end

	def new
		@notification = Notification.new
	end

	def create
		@notification = current_user.notifications.new(permit_params)
		@notification.save
		redirect_to notifications_path
	end

	def edit
		@notification = Notification.find_by(id: params[:id])
	end

	def update
		@notification = Notification.find_by(id: params[:id])
		@notification.update(permit_params)
		redirect_to notifications_path
	end

	def destroy
		@notification = Notification.find_by(id: params[:id])
		@notification.destroy
		redirect_to notifications_path
	end
end