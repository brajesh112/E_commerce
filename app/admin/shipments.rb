ActiveAdmin.register Shipment do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  menu :if => proc{ current_user.admin? }
  scope :all
  Shipment.all.map{|ship| scope ("#{ship.status}") {|scope| scope.where(status: "#{ship.status}")}}
  permit_params :status, :expected_delivery, :order_id
  # or
  #
  # permit_params do
  #   permitted = [:status, :expected_delivery, :order_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  index do
    selectable_column
    id_column
    column :status
    column :expected_delivery
    column :order_id
    column :created_at
    column :updated_at
    actions
  end
  show do
    attributes_table do
      row :status
      row :expected_delivery
      row :order_id
      row :created_at
      row :updated_at
    end
  end
  form do |f|
    f.inputs do
      f.input :status
      f.input :expected_delivery
    end
    actions
  end
end
