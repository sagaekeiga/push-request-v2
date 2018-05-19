class Reviewers::BaseController < ApplicationController
  before_action :authenticate_reviewer!
  before_action :set_skill!

  def set_skill!
    redirect_to skills_reviewers_skillings_url, danger: t('reviewers.skillings.edit.alert') if current_reviewer.skillings.none?
  end
end
