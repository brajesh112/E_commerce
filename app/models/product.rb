class Product < ApplicationRecord
	has_many_attached :images
	validates :stock, presence: true
	has_many :line_items
	belongs_to :user
end
