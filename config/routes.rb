DanceNetwork::Application.routes.draw do
  
  devise_for :users, :controllers => { :registrations => "registrations" }
 
  resources :textposts, only: [:create, :destroy] do
    resources :comments, only: [:create, :destroy]
  end
  resources :relationships, only: [:create, :destroy]

  resources :messages, only: [:index, :new, :create, :show, :destroy] do
    member do
      post 'reply'
    end
  end
  
  root  'static_pages#home'

  get '/users/:id', to: 'users#show', as: :user_root
  get '/users', to: 'users#index', as: :users_index
  get '/users/:id/following', to: 'users#following', as: :following_user
  get '/users/:id/followers', to: 'users#followers', as: :followers_user
  get '/activities', to: 'activities#index', as: :activities_index

  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
end
