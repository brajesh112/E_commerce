require "tempfile"

class ProductImportJob < ApplicationJob
  queue_as :default

  def perform(import_id)
    import = ProductImport.find_by(id: import_id)
    return if import.nil? || !import.file.attached?

    import.update(status: "processing")

    # Copy the stored blob (S3 in production) to a local .xlsx tempfile so the
    # importer, which opens an .xlsx path, accepts it.
    Tempfile.create(["product_import", ".xlsx"], Rails.root.join("tmp")) do |tempfile|
      tempfile.binmode
      tempfile.write(import.file.download)
      tempfile.flush

      result = ProductImporter.new(tempfile.path, import.user).call
      import.update(
        status: "completed",
        created_count: result.created,
        row_errors: result.errors
      )
    end
  rescue StandardError => e
    import&.update(status: "failed", row_errors: [{ row: nil, messages: [e.message] }])
  end
end
