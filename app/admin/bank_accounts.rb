ActiveAdmin.register BankAccount do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :account_no, :ifsc_code, :bank, :branch_name, :city, :user_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:account_no, :ifsc_code, :bank, :branch_name, :city, :user_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
