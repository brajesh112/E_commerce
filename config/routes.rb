Rails.application.routes.draw do
	ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: {
        sessions: 'sessions/sessions',
        registrations: 'sessions/registrations'
      }
  resources :addresses,:bank_accounts, except: [:show]
  resources :carts, only: [:index, :new]
  resources :products, :shipments, only: [:index, :show]
  resources :orders, except: [:edit] do
    get 'detail_pdf', to: 'orders#order_pdf'
  end
  resources :shipments,:tracking_orders, only: [:show]
  resources :seller_signups, only: [:index]
  resources :line_items, :notifications, :otps
  resources :payments

  post "admin/products/add_sub", to: "admin/products#add_sub"
  post "admin/products/variant", to: "admin/products#variant"
  post "admin/products/size_of_product", to: "admin/products#size_of_product"
  root to: "homes#index"
  match '*unmatched', to: 'application#not_found_method', via: :all, constraints: lambda { |req| (req.path.exclude? 'active_storage')}
end
