class Product < ApplicationRecord
	has_many_attached :images
	validates :stock, presence: true
	has_many :line_items, dependent: :destroy
	belongs_to :user
end
