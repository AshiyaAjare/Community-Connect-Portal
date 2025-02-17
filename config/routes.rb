Rails.application.routes.draw do
  get "moderation_logs/index"
  # devise_for :users

  # config/routes.rb
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'devise/passwords',
    invitations: 'users/invitations'
  }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      post '/auth/login', to: 'authentication#login'
      resources :users, only: [:index, :show, :create, :update]
      resources :tags
      resources :queries
      resources :queries do
        resources :responses, only: [:create]  
      end
      resources :moderation_logs do
        # patch "/restore_query/:id", to: "queries#restore", as: :restore_query
        # patch "/restore_response/:id", to: "responses#restore", as: :restore_response
        post :restore, on: :member
      end
    end
    resources :responses, only: [:index, :show, :edit, :destroy]
  end
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root to: "users#index"

  resources :users do
    post :invite, on: :member
  end
  resources :tags
  resources :queries do
    member do
      patch :update_status
      patch :update_flag
    end
    resources :responses, only: [:create]  
  end
  
  resources :responses do
    member do
      patch :upvote
      patch :downvote
      patch :like
      patch :toggle_approval
      patch :toggle_flag
    end
  end

  resources :moderation_logs, only: [:index, :show] do
    patch "/restore_query/:id", to: "queries#restore", as: :restore_query
    patch "/restore_response/:id", to: "responses#restore", as: :restore_response
    patch :restore, on: :member
  end

  
  #post '/auth/login', to: 'authentication#login'

end
