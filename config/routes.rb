Rails.application.routes.draw do
  # devise_for :users

  # config/routes.rb
devise_for :users, controllers: {
  registrations: 'users/registrations',
  sessions: 'users/sessions',
  passwords: 'devise/passwords'
}



  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      post '/auth/login', to: 'authentication#login'
      resources :users, only: [:index, :show, :create, :update]
      resources :tags
    end
  end
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root to: "users#index"

  resources :users
  resources :tags
  #post '/auth/login', to: 'authentication#login'

  # Defines the root path route ("/")
  # root "posts#index"
end
