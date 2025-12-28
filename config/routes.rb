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

  get '/figures/:figure_type', to: 'size_figures#index'
  delete '/figures/:figure_type/:id', to: 'size_figures#destroy'

  resources :size_figures do
    resources :update_size_figure

    get :sam_contour
  end


  # resources :lithics do
  #   member do
  #     get :sam_contour
  #   end
  #   # resources :update_lithic
  # end
  resources :kurgans
  resources :sites
  resources :maps
  resources :graves do
    resources :update_grave do
      collection do
        get :skeleton_keypoints
      end
    end
    collection do
      get :stats
      get :orientations
    end

    member do
      get :related
      post :save_related
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
  resources :ceramics
  resources :publications do
    resources :pages do
      collection do
        get :by_page_number
      end
    end
    member do
      get :export
      get :export_lithics
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

  post "/graphql", to: "graphql#execute"

  root "graves#root"
end
