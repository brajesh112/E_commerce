class Address < ApplicationRecord
	belongs_to :user
	has_many :orders, dependent: :destroy
	validates :city, :house_no, :street, :landmark, :state, :pin, :country, presence: true
	validates :city, :country, format: { with: /\A[A-Za-z]+\z/}
end