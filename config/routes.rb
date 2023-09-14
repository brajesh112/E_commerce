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
  resources :orders, except: [:update, :edit]
  resources :shipments, only: [:show]
  resources :seller_signups, only: [:index]
  resources :line_items, :tracking_orders,  :notifications, :otps
  root to: "homes#index"
  match '*unmatched', to: 'application#not_found_method', via: :all, constraints: lambda { |req| (req.path.exclude? 'active_storage')}
end
