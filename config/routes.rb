Rails.application.routes.draw do
  devise_for :users

  resources :nurseries
  resources :crops

  resource :calendar, only: :show

  get "/cashflow", to: "cashflow#index", as: :cashflow
  resources :cashflow_entries, except: [ :index, :show ]

  get  "/database/export", to: "database#export", as: :database_export
  post "/database/import", to: "database#import", as: :database_import

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
