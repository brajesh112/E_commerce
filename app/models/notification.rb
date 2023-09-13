class Notification < ApplicationRecord
	belongs_to :user
	belongs_to :notificable, polymorphic: true
end
