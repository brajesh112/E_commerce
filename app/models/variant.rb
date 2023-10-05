class Variant < ApplicationRecord
	has_many :products
	belongs_to :sub_category
	has_many :product_size
end
