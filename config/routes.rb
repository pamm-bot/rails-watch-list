Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "lists#index"

  resources :lists, only: [ :index, :show, :create, :update, :destroy ] do
    resources :bookmarks, only: [ :create ]
  end

  resources :bookmarks, only: [ :destroy, :update ] do
    resources :reviews, only: [ :create ]
  end
  resources :movies, only: [ :index, :create ]
end
