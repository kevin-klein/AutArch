Rails.application.routes.draw do
  resources :sites
  resources :graves
  resources :figures
  resources :pages
  resources :images
  resources :page_images
  resources :publications do
    get :analyze, on: :member
  end
end
