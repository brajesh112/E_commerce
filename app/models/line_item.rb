class LineItem < ApplicationRecord
	self.table_name = :items
	belongs_to :cart
	belongs_to :product
	validates :quantity, comparison: {greater_than: 0}
end
