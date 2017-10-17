require 'can_access_kibana'
require "resque_web"

Rails.application.routes.draw do

  # root to: redirect(subdomain: 'lionsclub')

  root 'application#index'

  constraints CanAccessKibana do
    ResqueWeb::Engine.eager_load!
    mount ResqueWeb::Engine => "/resque"
  end

  namespace :api do
    namespace :v1 do
      post '/auth/persona/login',  to: 'sessions#signin_persona'
      post '/auth/persona/logout', to: 'sessions#signout_persona'
      post '/auth/persona/signup',  to: 'sessions#signup_persona'
      resources :users do
        member do
          post 'rate'
          post 'promote'
          post 'demote'
          post 'enable'
          post 'disable'
        end
        collection do
          post 'invite'
        end
        collection do
          post 'addTag'
          post 'removeTag'
        end
      end
      resources :requests do
        member do
          post 'rate'
        end
      end
      resources :comments do
        member do
          post 'rate'
        end
      end
      resources :conversations do
        member do
          post 'rate'
        end
      end
      resources :tags
      resources :ratings
      resources :contacts
      resources :notifications do
        member do
          post 'done'
        end
      end
      post '/payments/authorize', to: 'payments#authorize'
      get '/payments/redirect_url', to: 'payments#redirect_url'
      get '/payments/request_id', to: 'payments#request_id'
    end
  end

  namespace :admin do
    get '/', to: 'dashboard#index'
    resources :users
    resources :requests
    resources :conversations
    resources :settings
    resources :acts_as_taggable_on_tags
    resources :newsletters do
      member do
        post 'send_me'
        post 'send_admin'
        post 'send_everybody'
      end
    end
    resources :logs
  end

  resources :users, only: [:index]
  resources :users, path: '/u', except: [:index] do
    collection do
      get 'notifications'
      get 'edit'
      get 'invite'
    end
  end
  resources :tags, path: '/categories', only: [:index]
  resources :tags, path: '/category', except: [:index]
  resources :conversations, path: '/conversation', only: [:show]
  resources :requests, path: '/b'
  get '/discover', to: 'application#discover'
  get "/img" => "proxy#img"
  get '/browser_not_supported', to: 'application#browser_not_supported'

  get "/oauth2callback", to: "oauth_services#callback"
  get "/oauth2authentication", to: "oauth_services#authentication"

  match "/websocket", to: WebsocketRails::ConnectionManager.new, via: [:get, :post]

  get "*path.html" => "application#index", :layout => 0
  get 'unsubscribe/:token' => 'application#unsubscribe', as: :unsubscribe
  get '*path' => 'application#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
