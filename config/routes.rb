DanceNetwork::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }
  resources :textposts, only: [:create, :destroy]
  
  root  'static_pages#home'

  get '/users/:id', to: 'users#show', as: :user_root
  get '/users', to: 'users#index', as: :users_index

  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
end
