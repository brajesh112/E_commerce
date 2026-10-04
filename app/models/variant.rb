class Variant < ApplicationRecord
	include Codeable
	code_source :variant_name
	has_many :products
	belongs_to :sub_category
	has_many :product_size
end
