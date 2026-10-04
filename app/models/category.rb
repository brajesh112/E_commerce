class Category < ApplicationRecord
	include Codeable
	code_source :categories_type
	has_many :products
	has_many :sub_categories
end
