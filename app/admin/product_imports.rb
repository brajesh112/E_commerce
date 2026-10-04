ActiveAdmin.register ProductImport do
  menu parent: "Products", label: "Product Imports"

  actions :index, :show

  # Sellers only ever see their own import runs.
  controller do
    def scoped_collection
      current_user.seller? ? ProductImport.where(user_id: current_user.id) : super
    end
  end

  index do
    id_column
    column :user
    column :status
    column :created_count
    column("Errors") { |pi| pi.row_errors.size }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :user
      row :status
      row :created_count
      row("File") do |pi|
        link_to("Download", url_for(pi.file)) if pi.file.attached?
      end
      row :created_at
      row :updated_at
    end

    panel "Row errors" do
      if product_import.row_errors.any?
        table_for product_import.row_errors do
          column("Row") { |e| e["row"] || e[:row] }
          column("Messages") { |e| Array(e["messages"] || e[:messages]).join(", ") }
        end
      else
        para "No errors."
      end
    end
  end
end
