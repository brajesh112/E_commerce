class Product < ApplicationRecord
	# attr_accessor :offer_type_ids
	include ApplicationHelper
	has_many_attached :images
	validates :stock, presence: true, comparison: {greater_than_or_equal_to: 0}
	has_many :line_items, dependent: :destroy
	has_and_belongs_to_many :offer_types
	belongs_to :user
	belongs_to :category
	validates :product_name, :price, :description, presence: true
	enum :product_type,[:national, :personal]
	has_one :discount
	has_many :notifications, as: :notificable
	after_create :notification_method
	after_update :notification_update
	def discount_price
		self.price - (self.price * self.discount.discount_amount)/100
	end
	private
		def notification_method
			add_notification(self, "Your Product Created")
		end

		def notification_update
			add_notification(self, "Your Product Updated")
		end
end
