class WebDomainConstraint
  # Review Appsでは毎回ドメインが変更されるのでドメイン制約をつけない
  def self.matches?(request)
    ENV['REVIEW_APP'].present? || request.host == (ENV['WEB_DOMAIN'])
  end
end

class AdminDomainConstraint
  # Review Appsでは毎回ドメインが変更されるのでドメイン制約をつけない
  def self.matches?(request)
    ENV['REVIEW_APP'].present? || request.host == (ENV['ADMIN_DOMAIN'])
  end
end

Rails.application.routes.draw do
  scope module: :api do
    scope module: :v1 do
      namespace :github_apps do
        post :receive_webhook
      end
    end
  end

  constraints(WebDomainConstraint) do
    root to: 'welcome#index'
    get '/auth/github/callback', to: 'connects#github'
    devise_scope :reviewee do
      post '/auth/:action/callback',
        controller: 'connects',
        constraints: { action: /github/ }
    end

    #
    # Reviewee
    #

    devise_for :reviewees, path: 'reviewees', controllers: {
      registrations: 'reviewees/registrations',
      confirmations: 'reviewees/confirmations',
      sessions: 'reviewees/sessions'
    }

    namespace :reviewees do
      get :dashboard, :pulls, :repos, :synchronizes
      get 'settings/integrations'
      resources :pulls, only: %i(update)
    end

    #
    # Reviewer
    #

    devise_for :reviewers, path: 'reviewers', controllers: {
      registrations: 'reviewers/registrations',
      confirmations: 'reviewers/confirmations',
      sessions: 'reviewers/sessions'
    }

    namespace :reviewers do
      get :dashboard, :my_page
      get 'settings/integrations'
      resource :skillings, only: %i(update) do
        get :skills, to: 'skillings#edit'
      end
      resources :pulls, only: %i(show update), param: :token do
        get :files
        resources :reviews, only: %i(create) do
          get :file, to: 'reviews#new', on: :collection
        end
      end
      resources :review_comments, only: %i(create update destroy show)
    end

    #
    # Admin
    #
    devise_for :admins, path: 'admins', controllers: {
      registrations: 'admins/registrations',
      confirmations: 'admins/confirmations',
      sessions: 'admins/sessions'
    }

    namespace :admins do
      get :dashboard
      resources :reviewers, only: %i(show update)
    end

    if !Rails.env.production? && defined?(LetterOpenerWeb)
      mount LetterOpenerWeb::Engine, at: '/letter_opener'
    end

    if !Rails.env.production? && defined?(Sidekiq::Web)
      mount Sidekiq::Web => '/sidekiq'
    end
  end
end
