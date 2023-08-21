Rails.application.routes.draw do
  devise_for :users
  resources :products, :carts, :line_items
  # get "/cart", to: "carts#index"
  # post "/cart.id", to: "carts#add"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root to: "homes#index"
  # "devise/registrations#new"
end
