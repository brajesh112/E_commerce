Rails.application.routes.draw do
	devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: {
        sessions: 'sessions/sessions'
      }
  resources :products, :carts, :line_items, :addresses, :orders, :shipments, :tracking_orders 
  root to: "homes#index"
end
