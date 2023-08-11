Rails.application.routes.draw do
  resources :messages, only: [:create] do
    collection do
      post :delivery_status
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
