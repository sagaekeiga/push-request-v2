class Reviewers::PullsController < Reviewers::BaseController
  before_action :set_pull, only: %i(show update files)
  before_action :set_changed_files, only: %i(show files)
  before_action :check_reviewer, only: %i(show update)

  def show
    @review = Review.new
    @pull = Pull.includes(changed_files: :review_comments).order('review_comments.created_at asc').friendly.find(params[:token])
    @double_review_comments = @pull.changed_files.map{ |changed_file| changed_file.review_comments.includes(:reviewer) }
    respond_to do |format|
      format.html
      format.json do
        render json: {
          body: @pull.body
        }
      end
    end
  end

  def files
  end

  def update
    case params[:status]
    when 'request_reviewed', 'canceled'
      @pull.agreed!
      @pull.update(reviewer: current_reviewer)
    when 'agreed'
      return redirect_to [:reviewers, @pull], success: t('.already_reviewed') if current_reviewer.reviews.find_by(pull: @pull).present?
      current_reviewer.cancel_review_comments!(@pull)
      @pull.canceled!
      @pull.update(reviewer: nil)
      return redirect_to [:reviewers, @pull], success: t('reviewers.views.canceled')
    end
    redirect_to file_reviewers_pull_reviews_url(@pull), success: t('.success')
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:token] || params[:pull_token])
  end

  def set_changed_files
    @changed_files = @pull.last_committed_changed_files.decorate
  end

  # 他のレビュワーに承認されたら情報保護的に非公開にしたい
  def check_reviewer
    redirect_to reviewers_dashboard_url if @pull.agreed? && !@pull.reviewer?(current_reviewer)
  end
end
