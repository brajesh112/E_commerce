Rails.application.routes.draw do
  devise_for :users
  resources :products, :carts, :line_items, :addresses, :orders, :shipments, :tracking_orders 
  root to: "homes#index"
end
