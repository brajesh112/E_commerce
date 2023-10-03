ActiveAdmin.register Transaction do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :admin_commision, :seller_earning, :tax, :total_amount, :user_id, :order_id, :quantity, :product, :status
  #
  # or
  #
  # permit_params do
  #   permitted = [:admin_commision, :seller_earning, :tax, :total_amount, :user_id, :order_id, :quantity, :product, :status]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end


    index do
    selectable_column
    id_column
    column :admin_commision
    column :seller_earning
    column :tax
    column :total_amount
    column :user
    column :order 
    column :quantity
    column :product
    column :status
    actions do
    link_to "pay",orders_path, class: "member_link" 
    end
  end

  controller do
    def scoped_collection
      current_user.admin? ? Transaction.all : Transaction.where(user_id: current_user.id)
    end
  end
end
