DanceNetwork::Application.routes.draw do
  get "users/index"

  devise_for :users, :controllers => { :registrations => "registrations" }
  
  root  'static_pages#home'

  get '/users/:id', to: 'users#show', as: :user_root

  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
end
