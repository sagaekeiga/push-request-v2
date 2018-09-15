class Reviewees::IssuesController < Reviewees::BaseController
  before_action :set_repo, only: %i(index show update)
  before_action :set_issue, only: %i(index show update)
  skip_before_action :verify_authenticity_token, only: %i(update)

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
    respond_to do |format|
      format.html
      format.json do
        render json: {
          publish: @issue.publish
        }
      end
    end
  end

  private

  def set_repo
    @repo = current_reviewee.repos.find(params[:repo_id])
  end

   def set_issue
     @issue = @repo.issues.find_by(reviewee: current_reviewee, id: params[:id])
   end
end