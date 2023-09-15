ActiveAdmin.register TermsAndCondition do
   # before_action :check_seller
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # actions :index
   permit_params :terms, :status, :user_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:terms, :status, :user_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  # controller do
  #   def index 
  #     TermsAndCondition.where(user_id: current_user.id)
  #   end

  #   def edit


  #   def check_seller

  #   end
  # end

  # form do |f|
  #   f.inputs do
  #     f.input :terms, disabled: true if current_user.admin? 
  #     f.input :status
  #   end
  #   actions
  # end

  # index do
  #   column :terms
  # end

end
