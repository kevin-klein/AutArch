Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  resources :users
  resources :periods
  resources :bones
  resources :y_haplogroups
  resources :mt_haplogroups
  resources :genetics
  resources :anthropologies
  resources :cultures
  resources :taxonomies
  resources :tags
  resources :chronologies do
    resources :c14_dates
  end
  resources :lithics
  resources :kurgans
  resources :sites
  resources :maps
  resources :graves do
    resources :update_grave
    collection do
      get :stats
    end
  end
  resources :figures do
    member do
      get :preview
    end
  end
  resources :skeletons do
    resources :stable_isotopes
  end
  resources :page_images
  resources :publications do
    resources :pages
    member do
      post :update_site
      get :assign_site
      get :assign_tags
      post :update_tags
      get :progress
      get :stats
      get :radar
      get :analyze
      get :summary
    end
    # get :delete, on: :member
  end

  get "/login", to: "user_sessions#login"
  get "/logout", to: "user_sessions#logout"
  post "/login", to: "user_sessions#code"
  post "/login_code", to: "user_sessions#login_code"

  root "graves#root"
end
