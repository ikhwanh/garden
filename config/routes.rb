Rails.application.routes.draw do
  devise_for :users
  patch "/farm_profile", to: "farm_profile#update", as: :farm_profile

  resources :nurseries
  resources :crops
  resources :presets

  get "/cashflow", to: "cashflow#index", as: :cashflow
  resources :cashflow_entries, except: [ :index, :show ]

  get  "/database/export", to: "database#export", as: :database_export
  post "/database/import", to: "database#import", as: :database_import

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :dashboard do
    get "monitoring",    to: "monitoring#index",         as: :monitoring
    get "finance",       to: "finance#index",            as: :finance
    get  "tools",              to: "tools#index",              as: :tools
    post "tools/seed_presets", to: "tools#seed_presets",       as: :seed_presets
    get "detail_panel",  to: "monitoring#detail_panel",  as: :detail_panel

    get "fertilization_calendar",        to: "fertilization_calendar#index",  as: :fertilization_calendar
    get "fertilization_calendar/day",    to: "fertilization_calendar#day",    as: :fertilization_calendar_day
    get "fertilization_calendar/export", to: "fertilization_calendar#export", as: :fertilization_calendar_export
  end

  root "dashboard/monitoring#index"
end
