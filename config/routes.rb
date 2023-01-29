Rails.application.routes.draw do
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
    collection do
      get :stats
    end
  end
  resources :figures
  resources :pages
  resources :images
  resources :skeletons do
    resources :stable_isotopes
  end
  resources :page_images
  resources :publications do
    get :stats
    get :analyze, on: :member
  end

  root 'graves#index'
end
