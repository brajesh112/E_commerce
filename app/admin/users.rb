ActiveAdmin.register User do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  menu :if => proc{ current_user.admin? }
  scope :all
  scope ('admin') {|scope| scope.where(role: 'admin')}
  scope ('seller') {|scope| scope.where(role: 'seller')}
  scope ('buyer') {|scope| scope.where(role: 'buyer')}
   
  permit_params :email, :encrypted_password, :name, :phone_number, :role, :fssi_no, :notification_status
  #
  # or
  #
  # permit_params do
  #   permitted = [:email, :encrypted_password, :name, :phone_number, :role, :reset_password_token, :reset_password_sent_at, :remember_created_at]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  controller do
    def scoped_collection
      current_user.admin? ? User.all : User.where(id: current_user.id)
    end
  end
end