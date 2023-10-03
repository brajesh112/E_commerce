ActiveAdmin.register Order do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  scope :all
  scope ('pending') {|scope| scope.where(status: 'pending')}
  scope ('paid') {|scope| scope.where(status: 'paid')}
  scope ('canceled') {|scope| scope.where(status: 'cancel')}
  scope ('refunded') {|scope| scope.where(status: 'refunded')}
  permit_params :description, :payment_method, :status, :track_id, :user_id, :address_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:description, :payment_method, :status, :track_id, :user_id, :address_id, :product_ids]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form do |f|
    f.input :status
    actions
  end

  index do
    selectable_column
    id_column
    column :description do |order|
      order.description.html_safe
    end
    column :status
    column :user
    column :track_id 
    column :payment_method
    column :address do |order|
      order.show_model.html_safe
    end
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :description do |order|
      order.description.html_safe
    end
      row :status
      row :track_id
      row :user
      row :payment_method
      row :address do |order|
        order.show_model.html_safe
      end
      row :created_at
      row :updated_at
    end
  end

  controller do
    def scoped_collection
      current_user.admin? ?Order.all : Order.joins(:products).where("products.user_id" => current_user)
    end
  end
end
