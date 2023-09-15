ActiveAdmin.register OfferType do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
   menu :if => proc{ current_user.admin? }
   permit_params :name, :discount_percent
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :discount_percent]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
