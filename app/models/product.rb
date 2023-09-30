class Product < ApplicationRecord
	paginates_per 5
	include ApplicationHelper
	has_many_attached :images, dependent: :destroy
	validates :stock, presence: true, comparison: {greater_than_or_equal_to: 0}
	has_many :line_items, dependent: :destroy
	has_many :order_items, dependent: :destroy
	has_and_belongs_to_many :offer_types, dependent: :destroy
	belongs_to :user
	belongs_to :category
	validates :product_name, :price, :description, presence: true
	enum :product_type,[:national, :personal]
	has_one :discount, dependent: :destroy
	has_many :notifications, as: :notificable
	after_create :notification_method
	after_update :notification_update
	has_and_belongs_to_many :orders, dependent: :destroy

	private
		def notification_method
			add_notification(self, "Your Product Created")
		end

		def notification_update
			add_notification(self, "Your Product Updated")
		end
end
