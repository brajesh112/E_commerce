ActiveAdmin.register SubCategory do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
   permit_params :name, :category_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :category_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  form do |f|
    f.inputs do 
      f.input :category, as: :select, collection: Category.all.map{|category| [category.categories_type, category.id]}
      f.input :name
    end
    actions
  end

  index do
    selectable_column
    id_column
    column :name
    column :category do |sub_category|
      sub_category.category.categories_type
    end
    column :created_at
    column :updated_at
    actions
  end

end
