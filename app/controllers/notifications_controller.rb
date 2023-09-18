class NotificationsController < ApplicationController
	before_action :authenticate_user
	before_action :authenticate_user!

	def index
		@notifications = current_user.notifications.all.reverse
		@time = DateTime.now
	end

	# def show
	# 	@notification = Notification.find_by(id: params[:id])
	# 	return redirect_to root_path, alert: "Notification not found" unless @notification.present?
	# end

	# def new
	# 	@notification = current_user.notifications.new(title: params[:title], description: params[:description])
	# 	@notification.save
	# 	redirect_to notifications_path
	# end

	# def edit
	# 	@notification = Notification.find_by(id: params[:id])
	# 	return redirect_to root_path, alert: "Notification not found" unless @notification.present?
	# end

	# def update
	# 	@notification = Notification.find_by(id: params[:id])
	# 	return redirect_to root_path, alert: "Notification not found" unless @notification.present?
	# 	@notification.update()
	# 	redirect_to notifications_path
	# end

	# def destroy
	# 	@notification = Notification.find_by(id: params[:id])
	# 	return redirect_to root_path, alert: "Notification not found" unless @notification.present?
	# 	@notification.destroy
	# 	redirect_to notifications_path
	# end
end