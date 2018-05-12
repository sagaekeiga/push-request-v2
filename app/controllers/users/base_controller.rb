class Users::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :connect_github!

  def connect_github!
    redirect_to users_settings_integrations_url, danger: t('users.settings.integrations.alert.danger') if current_user.github_account.nil?
  end
end
