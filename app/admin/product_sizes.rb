ActiveAdmin.register ProductSize do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
   permit_params :variant_id, :size
  #
  # or
  #
  # permit_params do
  #   permitted = [:variant_id, :size]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form do |f|
    f.inputs do 
      f.input :variant, as: :select, collection: Variant.all.map{|variant| [variant.variant_name, variant.id]}
      f.input :size
    end
    actions
  end

  index do
    selectable_column
    id_column
    column :size
    column :variant do |property|
      property.variant.variant_name
    end
    column :created_at
    column :updated_at
    actions
  end
end
