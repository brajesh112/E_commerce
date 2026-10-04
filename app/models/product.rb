class Product < ApplicationRecord
	paginates_per 5
	include ApplicationHelper
	has_many :product_colors, dependent: :destroy
	has_many_attached :images, dependent: :destroy
	accepts_nested_attributes_for :product_colors, allow_destroy: true
	validates :stock, presence: true, comparison: {greater_than_or_equal_to: 0}
	has_many :line_items, dependent: :destroy
	has_many :order_items, dependent: :destroy
	has_and_belongs_to_many :offer_types, dependent: :destroy
	has_many :sizes ,dependent: :destroy
	has_many :product_sizes,through: :sizes
	accepts_nested_attributes_for :sizes, allow_destroy: true
	belongs_to :user
	belongs_to :category
	# Vestigial: the category hierarchy moved to category + variant (which owns
	# the sub_category). There is no products.sub_category_id column, so this
	# association is optional to keep products creatable.
	belongs_to :sub_category, optional: true
	belongs_to :variant
	validates :product_name, :price, :description, presence: true
	validates :price, numericality: { greater_than: 0 }
	validates :discount_price, numericality: { greater_than: 0 }, allow_nil: true
	validate :discount_price_not_above_price
	enum :product_type,[:national, :personal]
	has_one :discount, dependent: :destroy
	has_many :notifications, as: :notificable
	after_create :notification_method
	after_update :notification_update
	has_and_belongs_to_many :orders, dependent: :destroy

	private
		def discount_price_not_above_price
			return if discount_price.blank? || price.blank?
			errors.add(:discount_price, "can't be greater than price") if discount_price > price
		end

		def notification_method
			add_notification(self, "Your Product Created")
		end

		def notification_update
			add_notification(self, "Your Product Updated")
		end
end
