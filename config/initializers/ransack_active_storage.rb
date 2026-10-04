# ActiveAdmin/Ransack require every searchable model to allowlist its attributes
# and associations. ActiveStorage's models are not ApplicationRecord descendants,
# so the default allowlist in ApplicationRecord does not reach them. Admin pages
# that show attachments (product images, the bulk-import file) search through them,
# so allowlist their non-sensitive columns and associations here.
Rails.application.config.to_prepare do
  ActiveStorage::Attachment.class_eval do
    def self.ransackable_attributes(_auth_object = nil)
      %w[id name record_type record_id blob_id created_at]
    end

    def self.ransackable_associations(_auth_object = nil)
      %w[blob record]
    end
  end

  ActiveStorage::Blob.class_eval do
    def self.ransackable_attributes(_auth_object = nil)
      %w[id key filename content_type byte_size checksum service_name created_at]
    end

    def self.ransackable_associations(_auth_object = nil)
      %w[attachments]
    end
  end
end
