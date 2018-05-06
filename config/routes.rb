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
  devise_for :users, path: 'users', controllers: {
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
    sessions: 'users/sessions'
  }

  namespace :users do
    get :my_page
  end

  root to: 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
