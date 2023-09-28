class NotificationsController < ApplicationController
	before_action :authenticate_user
	before_action :authenticate_user!

	def index
		@notifications = current_user.notifications.all.reverse
		@time = DateTime.now
	end
end