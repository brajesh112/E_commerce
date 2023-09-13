class BankAccount < ApplicationRecord
	belongs_to :user
	has_many :notifications, as: :notificable
end
