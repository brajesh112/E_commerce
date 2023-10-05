ActiveAdmin.register Variant do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
   permit_params :category_comission, :variant_name, :sub_category_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:category_comission, :variant_name, :sub_category_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
    form do |f|
    f.inputs do 
      f.input :sub_category, as: :select, collection: SubCategory.all.map{|subcategory| [subcategory.name, subcategory.id]}
      f.input :variant_name
      f.input :category_comission
    end
    actions
  end

  index do
    selectable_column
    id_column
    column :variant_name
    column :sub_category do |variant|
      variant.sub_category.name
    end
    column :category_comission
    column :created_at
    column :updated_at
    actions
  end
  
end
