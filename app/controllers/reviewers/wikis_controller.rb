class Reviewers::WikisController < Reviewers::BaseController
  before_action :set_repo, only: %i(index show)
  before_action :set_repo, only: %i(index show)
  before_action :set_wikis, only: %i(index show)
  before_action :set_home_wiki, only: %i(index show)
  before_action :set_wiki, only: %i(show)
  def index
  end

  def show
  end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id])
  end

  def set_repo
    @repo = Repo.find(params[:repo_id])
  end

  def set_wikis
    @wikis = @repo.wikis.showing.where.not(title: 'Home')
  end

  def set_home_wiki
    @home_wiki = @repo.wikis.showing.find_by(title: 'Home')
  end

  def set_wiki
    @wiki = @repo.wikis.showing.find(params[:id])
  end
end
