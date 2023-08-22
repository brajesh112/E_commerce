class Order < ApplicationRecord
	belongs_to :user
	enum :payment_method, [:cash, :card, :upi]
	enum :status, [:order_placed, :in_transit, :out_for_delivery, :delivered]
end
