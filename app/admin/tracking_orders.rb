ActiveAdmin.register TrackingOrder do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
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
