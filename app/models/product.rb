class Product < ApplicationRecord
	# attr_accessor :offer_type_ids
	has_many_attached :images
	validates :stock, presence: true, comparison: {greater_than_or_equal_to: 0}
	has_many :line_items, dependent: :destroy
	has_and_belongs_to_many :offer_types
	belongs_to :user
	belongs_to :category
	validates :product_name, :price, :description, presence: true
	enum :product_type,[:national, :personal]
	has_one :discount

	def discount_price
		self.price - (self.price * self.discount.discount_amount)/100
	end
end
