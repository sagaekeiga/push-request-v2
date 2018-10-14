class WelcomeController < ApplicationController
  before_action :transition_dashboard!
  def index
    @pulls = Pull.request_reviewed.
      first(10)
      includes(:repo).
      order(created_at: :desc).
      select{ |pull| pull.repo.private == false }.
  end
end
