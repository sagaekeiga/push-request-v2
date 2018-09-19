class Reviewees::PullsController < Reviewees::BaseController
  before_action :set_repo, only: %i(update)
  before_action :set_pull, only: %i(update)
  before_action :set_pulls, only: %i(index)
  skip_before_action :verify_authenticity_token, only: %i(update)

  def index
    # @pulls = current_reviewee.pulls.includes(:repo).order(updated_at: :desc).page(params[:page])
  end

  def update
    case @pull.status
    when 'connected'
      @pull.request_reviewed!
    when 'request_reviewed'
      @pull.connected!
    end
    render json: { status: @pull.status }
  end

  private

  def set_repo
    @repo = current_reviewee.repos.find(params[:repo_id])
  end

  def set_pull
    @pull = current_reviewee.pulls.find(params[:id])
  end

  def set_pulls
    # @pulls = @repo.pulls.includes(:changed_files)
    @pulls = current_reviewee.pulls.includes(%i(repo changed_files)).order(updated_at: :desc).page(params[:page])
  end
end
