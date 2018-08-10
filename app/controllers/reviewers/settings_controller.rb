class Reviewers::SettingsController < Reviewers::BaseController
  skip_before_action :connect_github!
  def integrations
  end

  def index
  end
end
