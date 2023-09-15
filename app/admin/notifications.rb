ActiveAdmin.register Notification do

  actions :index
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :action, :notificable_type, :notificable_id, :user_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:action, :notificable_type, :notificable_id, :user_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  controller do
    def scoped_collection
      Notification.where(user_id: current_user.id)
    end
  end
  
end
