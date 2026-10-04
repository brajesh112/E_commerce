class SubCategory < ApplicationRecord
	include Codeable
	code_source :name
	has_many :products
	belongs_to :category
	has_many :variant
end
