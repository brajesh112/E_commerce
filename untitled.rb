form do |f|
    f.inputs do
      f.input :user 
      f.input :product_name
      f.input :stock
      f.input :price
      f.input :description
      f.input :category, as: :select, collection: Category.all.map{|category| [category.categories_type, category.id]}
      if f.object.images.attached?
        f.input :images, as: :file, input_html: { multiple: true },hint: image_tag(f.object.images.first, size: "100")
      else
        f.input :images, as: :file, input_html: { multiple: true }
      end 
    end
    actions
  end

  index do
    selectable_column
    id_column
    column :images do |ad|
        image_tag url_for(ad.images.first), size: "100"
    end
    column :product_name
    column :stock
    column :price
    column :description
    column :user 
    column :category do |product|
      product.category.categories_type
    end
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :images do |product|
        product.images.map{|image| image_tag url_for(image), size: "100"}
      end
      row :product_name
      row :stock
      row :price
      row :description
      row :user
      row :category do |product|
        product.category.categories_type
      end
      row :created_at
      row :updated_at
    end
  end
end
