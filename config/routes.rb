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
  resources :orders, except: [:edit]
  resources :shipments,:tracking_orders, only: [:show]
  resources :seller_signups, only: [:index]
  resources :line_items, :notifications, :otps
  resources :payments
  root to: "homes#index"
  match '*unmatched', to: 'application#not_found_method', via: :all, constraints: lambda { |req| (req.path.exclude? 'active_storage')}
end
