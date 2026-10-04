class Discount < ApplicationRecord
	belongs_to :product
	# Percentage off; bounded so a product's discount_price can never go negative.
	validates :discount_amount, presence: true,
		numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
