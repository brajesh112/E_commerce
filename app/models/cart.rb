class Cart < ApplicationRecord
	belongs_to :user
	has_many :line_items, dependent: :destroy

	def cart_method(product)
		product.product_type.eql?("national")? "₹40" : "Free"
	end

	def total_charges(items)
		# Flat ₹40 shipping if any line item is a national product, else free.
		# (The old "product.product_type" referenced a non-existent table alias.)
		national = Product.product_types[:national]
		items.joins(:product).where(products: { product_type: national }).exists? ? 40 : "Free"
	end
end
