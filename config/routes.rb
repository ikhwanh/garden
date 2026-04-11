Rails.application.routes.draw do
  devise_for :users

  resources :seeds
  resources :plants do
    resources :fertilizations, only: [ :new, :create ]
    resources :harvests, only: [ :new, :create ]
  end
  resources :fertilizations, except: [ :new, :create ]
  resources :harvests, except: [ :new, :create ]

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
