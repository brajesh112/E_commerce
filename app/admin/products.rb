ActiveAdmin.register Product do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :product_name, :stock, :price, :description, :user_id, :category_id, :offer_type_ids, :product_type, images:[]

  form do |f|
    f.inputs do
      f.input :user 
      f.input :product_name
      f.input :stock
      f.input :price
      f.input :description
      f.input :product_type
      f.input :offer_type_ids, as: :select, collection: OfferType.all.map{|offer| [offer.name, offer.id]},input_html: {multiple: true}

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
    column :offer_types
    column :product_type
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
      row :product_type
      row :category do |product|
        product.category.categories_type
      end
      row :created_at
      row :updated_at
    end
  end

  #
  # or
  #
  # permit_params do
  #   permitted = [:product_name, :stock, :price, :description, :user_id, :category_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  controller do
    def update
      # resource.permit_value(params)
      super
      offers_add
    end

    def create
      super
      offers_add
    end

    def offers_add
      @offers = OfferType.where(id: params[:product][:offer_type_ids].compact_blank)
      resource.offer_types.delete(resource.offer_types.where(id: resource.offer_types.excluding(@offers))) if resource.offer_types.present?
      resource.offer_types << @offers.excluding(resource.offer_types)
    end

  end
end
