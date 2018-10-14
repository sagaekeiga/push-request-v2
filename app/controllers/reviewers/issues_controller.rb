class Reviewers::IssuesController < Reviewers::BaseController
  before_action :set_repo, only: %i(index show)
  before_action :set_issue, only: %i(show)
  def index
    @issues = @repo.issues.showing
  end

  def show
  end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id])
  end

  def set_issue
    @issue = @repo.issues.find(params[:id])
  end
end
