class FeedController < ApplicationController
  def index
    @skill = Skill.find_by_name(params[:skill_name])
    @pulls = Pull.request_reviewed.order(created_at: :desc)
    if @skill
      repos = Repo.joins(:skillings).where(skillings: { skill_id: @skill.id })
      @pulls = Pull.request_reviewed.where(repo: repos).order(created_at: :desc).first(10)
    end
    respond_to do |format|
      format.rss { render layout: false }
    end
  end

  def rss
  end
end
