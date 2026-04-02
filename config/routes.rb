Rails.application.routes.draw do

  # Error handling routes
  match "/:code",
    to: "errors#show",
    via: :all,
    constraints: {
      code: Regexp.new(
        ErrorsController::VALID_STATUS_CODES.join("|")
      )
    }

  get "pages/about"
  namespace :admin do
    root to: "dashboard#index"
    resources :posts, only: [ :index, :destroy ]
    resources :users, only: [ :index ] do
      member do
        patch :promote
        patch :demote
      end
    end
  end
  devise_for :users, controllers: {
    confirmations: "users/confirmation"
  }
   # Defines the root path route ("/")
   root "topics#index"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resources :topics do
    member do
      patch :pin
      patch :unpin
    end

    resources :posts do
      member do
        patch :pin
        patch :unpin
      end
        resources :comments, only: [ :create, :edit, :update, :destroy ] do
        member do
          patch :pin
          patch :unpin
        end
      end
    end
  end

  get 'make-me-admin', to: 'application#make_me_admin'

  # tags
  get "/tagged", to: "posts#tagged", as: :tagged

  # profiles
  get "/users/:username", to: "profiles#show", as: "profile"
  get "/users/:username/edit", to: "profiles#edit", as: "edit_profile"
  patch "/users/:username", to: "profiles#update"

  get "/about", to: "pages#about"

  post "/wallet/check_availability", to: "wallet#check_availability"
  post "/wallet/connect",            to: "wallet#connect"
  post "/wallet/disconnect",         to: "wallet#disconnect"
end
