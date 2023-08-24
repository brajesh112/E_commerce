class Address < ApplicationRecord
	belongs_to :user
	has_many :orders
	validates :city, :house_no, :street, :landmark, :state, :pin, :country, presence: true
end