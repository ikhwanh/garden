Rails.application.routes.draw do
  devise_for :users

  resources :nurseries
  resources :crops
  resources :presets

  resource :calendar, only: :show

  get "/cashflow", to: "cashflow#index", as: :cashflow
  resources :cashflow_entries, except: [ :index, :show ]

  get  "/database/export", to: "database#export", as: :database_export
  post "/database/import", to: "database#import", as: :database_import

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :dashboard do
    get "monitoring",    to: "monitoring#index",         as: :monitoring
    get "finance",       to: "finance#index",            as: :finance
    get "tools",         to: "tools#index",              as: :tools
    get "preset_panel",  to: "monitoring#preset_panel",  as: :preset_panel
  end

  root "dashboard/monitoring#index"
end
