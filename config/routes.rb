Rails.application.routes.draw do
  resource :session
  resource :registration, only: [ :new, :create ]
  resources :passwords, param: :token
  get "up" => "rails/health#show", as: :rails_health_check

  get "locale/:locale", to: "locales#update", as: :locale,
      constraints: { locale: /en|it|fr/ }

  root "lists#index"

  resources :lists, only: [ :index, :show, :create, :update, :destroy ] do
    resources :bookmarks, only: [ :create ]
  end

  resources :bookmarks, only: [ :destroy, :update ] do
    resources :reviews, only: [ :create, :update, :destroy ]
  end
  resources :movies, only: [ :index, :create ]
end
