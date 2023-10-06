class ProductSize < ApplicationRecord
	belongs_to :variant
	has_many :sizes, dependent: :destroy
	has_many :products, through: :sizes, dependent: :destroy
end
