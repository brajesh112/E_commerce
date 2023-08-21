class LineItem < ApplicationRecord
	self.table_name = :items
	belongs_to :cart
	belongs_to :product
end
