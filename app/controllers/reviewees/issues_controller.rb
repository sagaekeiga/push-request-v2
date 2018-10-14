class Reviewees::IssuesController < Reviewees::BaseController
  before_action :set_repo, only: %i(index show update)
  before_action :set_issue, only: %i(index show update)
  skip_before_action :verify_authenticity_token, only: %i(update)
  before_action :check_reviweee_identity, only: %i(show)

  def index
    @issues = @repo.issues
  end

  def show
  end

  def update
    case @issue.publish
    when 'hidden'
      @issue.showing!
    when 'showing'
      @issue.hidden!
    end
    render json: { publish: @issue.publish }
  end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id])
  end

  def set_issue
    @issue = @repo.issues.find_by(
      resource_type: @repo.resource_type,
      resource_id: @repo.resource_id,
      id: params[:id]
    )
  end
end
