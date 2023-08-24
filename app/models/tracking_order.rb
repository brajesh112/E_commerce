class TrackingOrder < ApplicationRecord
	belongs_to :shipment
	enum :status, [:ordered, :shipped, :out_for_delivery, :arriving, :delivered]
	validates :status, :place, presence: true
end
