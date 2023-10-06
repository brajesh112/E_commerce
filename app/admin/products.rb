ActiveAdmin.register Product do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  scope :all
  
  Category.all.map{|cat| scope ("#{cat.categories_type}") {|scope| scope.joins(:category).where("categories.categories_type" => "#{cat.categories_type}")} }

  permit_params :product_name, :stock, :price, :description, :user_id, :category_id, :offer_type_ids, :product_type, :discount_price,:price_id,:sub_category_id, :variant_id,product_colors_attributes: [:id, :color, :_destroy => true], sizes_attributes: [:id, :product_size_id, :_destroy => true], images:[]

  form do |f|
    f.inputs do
      f.input :user, as: :select, collection: User.where(role: "seller").map{|seller| [seller.name, seller.id]}
      f.input :product_name
      f.input :stock
      f.input :price
      f.input :description
      f.input :product_type
      f.input :offer_type_ids, as: :select, collection: OfferType.all.map{|offer| [offer.name, offer.id]},input_html: {multiple: true}

      f.input :category, as: :select, collection: Category.all.map{|category| [category.categories_type, category.id]}

      div class: "d-none", id: "sub_div" do 
       f.input :sub_category, as: :select, collection: SubCategory.all.map{|sub_category| [sub_category.name, sub_category.id]}
      end

      div class: "d-none", id: "variant_div" do 
       f.input :variant, as: :select, collection: Variant.all.map{|variant| [variant.variant_name, variant.id]}
      end

      if f.object.images.attached?
        f.input :images, as: :file, input_html: { multiple: true },hint: image_tag(f.object.images.first, size: "100")
      else
        f.input :images, as: :file, input_html: { multiple: true }
      end 
    end
    f.inputs "ProductColor" do
      f.has_many :product_colors, allow_destroy: true, heading: false do |cd|
        cd.input :color
      end
    end
    f.inputs "ProductSize" do
      f.has_many :sizes, allow_destroy: true, heading: false do |cd|
        cd.input :product_size_id, as: :select, collection: ProductSize.all.map{|pro_size| [pro_size.size, pro_size.id]},input_html:{class: "size_options"}
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
  controller do
    def update
      super
      offers_add
    end

    def create
      super
      offers_add
      obj = StripePayment.create_product(resource)
      resource.price_id = obj.id
      resource.save
    end

    def offers_add
      @offers = OfferType.where(id: params[:product][:offer_type_ids].compact_blank)
      resource.offer_types.delete(resource.offer_types.where(id: resource.offer_types.excluding(@offers))) if resource.offer_types.present?
      resource.offer_types << @offers.excluding(resource.offer_types)

      @price = resource.discount.present? ? resource.price - (resource.price * resource.discount.discount_amount)/100 : resource.price

      resource.discount_price =  resource.offer_types.present? ? @price - (@price * resource.offer_types.first.discount_percent.to_i)/100 : @price
      resource.save
    end

    def scoped_collection
      current_user.seller? ? Product.where(user_id: current_user.id) : Product.all
    end

    def add_sub
      response = SubCategory.where(category_id: params[:id]).map{|subcat| [subcat.id, subcat.name]}
      respond_to do |format|
        format.json {render json: response}
      end
    end

    def variant
      response = Variant.where(sub_category_id: params[:id]).map{|variant| [variant.id, variant.variant_name]}
      respond_to do |format|
        format.json {render json: response}
      end
    end
    def size_of_product
      response = ProductSize.where(variant_id: params[:id]).map{|prod_size| [prod_size.id, prod_size.size]}
      respond_to do |format|
        format.json {render json: response}
      end
    end
  end
end