ActiveAdmin.register TermsAndCondition do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :terms
  #
  # or
  #
  # permit_params do
  #   permitted = [:terms]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  index do 
    column :terms
    actions
  end
  show do 
    attributes_table do
      row :terms
    end
  end
  
end
