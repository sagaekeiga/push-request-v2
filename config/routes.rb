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
      namespace :git_hub_apps do
        post :webhook
      end
    end
  end

  get '/auth/github/callback', to: 'connects#github'

  devise_scope :user do
    post '/auth/:action/callback',
      controller: 'connects',
      constraints: { action: /github/ }
  end

  devise_for :users, path: 'users', controllers: {
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
    sessions: 'users/sessions'
  }

  namespace :users do
    get :dashboard, :pulls, :repos
    get 'settings/integrations'
  end

  root to: 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
