Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    post "login", to: "sessions#create"

    resources :employees, only: [ :index, :show, :create, :update, :destroy ]
    get "stats", to: "stats#index"
    get "meta", to: "meta#index"
  end
end
