Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "lists#index"

  resources :lists, only: [ :index, :show, :create ]  do
    resources :bookmarks, only: [ :create ]
    resources :reviews, only: [ :create ]
  end

  resources :bookmarks, only: [ :destroy ]
end
