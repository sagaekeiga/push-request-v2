class WebDomainConstraint
  # Review Appsでは毎回ドメインが変更されるのでドメイン制約をつけない
  def self.matches?(request)
    ENV['REVIEW_APP'].present? || request.host == (ENV['REVIEWEE_DOMAIN'])
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
        post :webhook
      end
    end
  end

  constraints(WebDomainConstraint) do
    root to: 'welcome#index'
    get '/auth/github/callback', to: 'connects#github'
    devise_scope :user do
      post '/auth/:action/callback',
        controller: 'connects',
        constraints: { action: /github/ }
    end

    #
    # User
    #

    devise_for :users, path: 'users', controllers: {
      registrations: 'users/registrations',
      confirmations: 'users/confirmations',
      sessions: 'users/sessions'
    }

    namespace :users do
      get :dashboard, :pulls, :repos
      get 'settings/integrations'
    end

    #
    # Reviewer

    devise_for :reviewers, path: 'reviewers', controllers: {
      registrations: 'reviewers/registrations',
      confirmations: 'reviewers/confirmations',
      sessions: 'reviewers/sessions'
    }

    namespace :reviewers do
      get :dashboard
      # get 'settings/integrations'
    end
  end
end
