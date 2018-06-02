class Reviewers::BaseController < ApplicationController
  before_action :authenticate_reviewer!
  before_action :set_skill!
  before_action :connect_github!

  def set_skill!
    redirect_to skills_reviewers_skillings_url, danger: t('reviewers.skillings.edit.alert') if current_reviewer.skillings.none?
  end

  def connect_github!
    redirect_to reviewers_settings_integrations_url, danger: t('reviewees.settings.integrations.alert.danger') if current_reviewer.github_account.nil?
  end
end
