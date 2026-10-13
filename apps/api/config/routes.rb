Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"
      resource :session, only: %i[create show destroy]

      namespace :public do
        get "pages", to: "pages#index"
        get "pages/:locale/:slug", to: "pages#show", as: :page
        get "game-entities/:entity_type", to: "game_entities#index", as: :game_entities
      end

      namespace :admin do
        resources :templates, only: %i[index create] do
          member do
            post "revisions", action: :create_revision
            patch "revisions/:revision_id/publish", action: :publish_revision
          end
        end
        resources :pages, only: %i[index create] do
          member do
            post "revisions", action: :create_revision
            patch "publish/:revision_id", action: :publish
            patch "unpublish"
          end
        end
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
