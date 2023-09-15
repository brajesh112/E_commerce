ActiveAdmin.register TrackingOrder do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  menu :if => proc{ current_user.admin? }
  scope :all
  scope ('ordered') {|scope| scope.where(status: 'ordered')}
  scope ('shipped') {|scope| scope.where(status: 'shipped')}
  scope ('out_for_delivery') {|scope| scope.where(status: 'out_for_delivery')}
  scope ('arriving') {|scope| scope.where(status: 'arriving')}
  scope ('delivered') {|scope| scope.where(status: 'delivered')}
  permit_params :place, :status, :shipment_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:place, :status, :shipment_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form do |f|
    f.inputs do
      f.input :shipment_id, as: :select, collection: Shipment.all.map{|shipment| [shipment.id, shipment.id]}
      f.input :place
      f.input :status
    end
    actions
  end
end
