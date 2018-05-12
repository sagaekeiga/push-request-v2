class Users::SettingsController < Users::BaseController
  skip_before_action :connect_github!
  def integrations
  end
end
