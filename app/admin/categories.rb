ActiveAdmin.register Category do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
   permit_params :categories_type, :code

   index do
     selectable_column
     id_column
     column :categories_type
     column :code
     actions
   end
  #
  # or
  #
  # permit_params do
  #   permitted = [:categories_type]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
