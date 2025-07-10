Rails.application.routes.draw do
  require "sidekiq/web"

  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  mount Sidekiq::Web => "/sidekiq"

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # Chat routes
      root "chats#index"
      post "chat", to: "chats#chat"

      # Document routes
      resources :documents, only: [ :index, :create, :destroy ]
    end
  end
end
