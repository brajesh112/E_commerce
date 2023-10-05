class SubCategory < ApplicationRecord
	has_many :products
	belongs_to :category
	has_many :variant
end
