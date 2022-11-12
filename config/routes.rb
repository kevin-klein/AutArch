Rails.application.routes.draw do
  resources :graves
  resources :figures
  resources :pages
  resources :images
  resources :page_images
  resources :publications do
    get :analyze, on: :member
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
