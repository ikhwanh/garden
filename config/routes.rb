Rails.application.routes.draw do
  devise_for :users

  resources :seeds
  resources :plants do
    resources :fertilizations, only: [ :new, :create ]
    resources :harvests, only: [ :new, :create ]
    post :quick_fertilize, on: :member
  end
  resources :fertilizations, except: [ :new, :create ]
  resources :harvests, except: [ :new, :create ]

  resource :calendar, only: :show

  get "/cashflow", to: "cashflow#index", as: :cashflow
  resources :cashflow_entries, except: [ :index, :show ]

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
