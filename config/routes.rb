Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  resources :periods
  resources :bones
  resources :y_haplogroups
  resources :mt_haplogroups
  resources :genetics
  resources :anthropologies
  resources :cultures
  resources :taxonomies
  resources :chronologies do
    resources :c14_dates
  end
  resources :kurgans
  resources :sites
  resources :maps
  resources :graves do
    resources :update_grave
    collection do
      get :stats
    end
  end
  resources :figures
  resources :skeletons do
    resources :stable_isotopes
  end
  resources :page_images
  resources :publications do
    resources :pages
    get :progress, on: :member
    get :stats
    get :analyze, on: :member
    # get :delete, on: :member
  end

  root 'graves#root'
end
