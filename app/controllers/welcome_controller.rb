class WelcomeController < ApplicationController
  before_action :transition_dashboard!
  def index
    @pulls = Pull.order(created_at: :desc).first(10)
  end
end
