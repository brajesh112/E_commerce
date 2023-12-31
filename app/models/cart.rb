class Cart < ApplicationRecord
	belongs_to :user
	has_many :line_items, dependent: :destroy

	def cart_method(product)
		product.product_type.eql?("national")? "₹40" : "Free"
	end

	def total_charges(items)
		items.joins(:product).where("product.product_type"=>"national").present? ? 40 : "Free"
	end
end
