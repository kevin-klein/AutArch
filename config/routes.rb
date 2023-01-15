Rails.application.routes.draw do
  resources :sites
  resources :graves do
    collection do
      get :stats
    end
  end
  resources :figures
  resources :pages
  resources :images
  resources :page_images
  resources :publications do
    get :analyze, on: :member
  end
end
