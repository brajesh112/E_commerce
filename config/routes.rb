Rails.application.routes.draw do
	ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: {
        sessions: 'sessions/sessions'
      }
  resources :addresses,:bank_accounts, except: [:show]
  # resources :carts, only: [:index, :show]
  resources :products, :carts, :line_items, :orders, :shipments, :tracking_orders,  :notifications
  root to: "homes#index"
  match '*unmatched', to: 'application#not_found_method', via: :all, constraints: lambda { |req| (req.path.exclude? 'active_storage')}
end
