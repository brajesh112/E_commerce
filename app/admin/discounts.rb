ActiveAdmin.register Discount do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :discount_amount, :product_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:discount_amount, :product_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form do |f|
    f.inputs do
      f.input :product_id, as: :select, collection: Product.all.map{|product|[product.product_name, product.id]}
      f.input :discount_amount
    end
    f.actions
  end
  

  
end
