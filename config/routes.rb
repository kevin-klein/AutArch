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

  resources :arrow_heads

  get '/figures/:figure_type', to: 'size_figures#index'
  delete '/figures/:figure_type/:id', to: 'size_figures#destroy'

  resources :size_figures do
    resources :update_size_figure

    get :sam_contour

    collection do
      post :boxes
      post :update_contour
      post :new_box
    end

    member do
      get :pattern_matches
      post :extract_identifier
      get :show_summary_sources
    end
  end

  resources :teams do
    # user assignments
    resources :team_memberships, only: [:new, :create, :destroy], module: :teams
    # publication assignments
    resources :team_publications, only: [:new, :create, :destroy], module: :teams
  end


  # resources :lithics do
  #   member do
  #     get :sam_contour
  #   end
  #   # resources :update_lithic
  # end
  scope :kiosk_configs do
    # Global kiosk config (single record)
    get '/kiosk_config.json', to: 'kiosk_configs#show', as: :kiosk_config_json
    get '/kiosk_config', to: 'kiosk_configs#kiosk_config', as: :kiosk_config
    post '/kiosk_config.json', to: 'kiosk_configs#create', as: :kiosk_config_json_create
    get '/kiosk_config/frontend', to: 'kiosk_configs#kiosk_config_frontend', as: :kiosk_config_frontend
    # Select ceramic view
    get '/select_ceramic', to: 'kiosk_configs#select_ceramic', as: :select_ceramic

    # JSON API for page selection
    get '/pages.json', to: 'kiosk_configs#pages', as: :kiosk_pages

    # JSON API for publications
    get '/publications.json', to: 'kiosk_configs#publications', as: :kiosk_publications

    # JSON API for figures on a page
    get '/kiosk_config/pages/:id/figures.json', to: 'kiosk_configs#page_figures', as: :kiosk_page_figures
  end
  resources :kurgans
  resources :sites
  resources :maps
  resources :graves do
    resources :update_grave do
      collection do
        get :skeleton_keypoints
      end
      member do
        post :extract_identifier
        get :show_summary_sources
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

  resources :ceramics do
    get :wizard, on: :collection
    member do
      get :similarities
    end
  end

  get '/ipai_showcase', to: 'ceramics#index'
  get '/light', to: 'arrow_heads#index'

  get '/ceramics/wizard', to: 'ceramics#wizard', as: :ceramic_wizard
  resources :analysis_wizards do
    member do
      put :advance_step
      post :step_1
      post :step_2
      post :step_3
      post :save_ceramic
      post :similar_ceramics
    end
  end
  resources :publications do
    resources :pages do
      member do
        post :update_boxes
      end
      collection do
        get :by_page_number
      end
    end
    member do
      get :export
      get :export_lithics_form
      post :export_lithics
      post :update_site
      get :assign_site
      get :assign_tags
      post :update_tags
      get :progress
      get :stats
      get :analysis
      get :radar
      get :analyze
      get :summary
      post :create_bovw_data
      get :bovw_setting
      get :similarities
      post :extract_text_summaries
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
