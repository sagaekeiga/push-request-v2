class WelcomeController < ApplicationController
  before_action :transition_dashboard!
  def index; end
end
