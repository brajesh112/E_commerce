class Product < ApplicationRecord
	has_many_attached :images
	validates :stock, presence: true
	has_many :line_items, dependent: :destroy
	has_many :orders, dependent: :destroy
	belongs_to :user
	enum :categories, [:clothes, :electronics, :home_appliances]
end
