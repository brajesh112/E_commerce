class Product < ApplicationRecord
	has_many_attached :images
	validates :stock, presence: true, comparison: {greater_than_or_equal_to: 0}
	has_many :line_items, dependent: :destroy
	belongs_to :user
	enum :categories, [:clothes, :electronics, :home_appliances]
	validates :product_name, :price, :description, :categories, presence: true
end
