Rails.application.routes.draw do
	ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: {
        sessions: 'sessions/sessions'
      }
  resources :products, :carts, :line_items, :addresses, :orders, :shipments, :tracking_orders, :bank_accounts, :notifications
  root to: "homes#index"
end
