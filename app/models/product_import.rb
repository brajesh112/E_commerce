class ProductImport < ApplicationRecord
  belongs_to :user
  has_one_attached :file, dependent: :destroy

  enum :status, { pending: "pending", processing: "processing",
                  completed: "completed", failed: "failed" }

  validates :file, presence: true
end
