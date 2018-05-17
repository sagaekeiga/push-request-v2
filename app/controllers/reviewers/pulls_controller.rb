class Reviewers::PullsController < Reviewers::BaseController
  before_action :set_pull, only: %i(show update)
  before_action :check_reviewer, only: %i(show update)

  def show
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
    @pull = Pull.find(params[:id])
  end

  # 他のレビュワーに承認されたら情報保護的に非公開にしたい
  def check_reviewer
    redirect_to reviewers_dashboard_url if @pull.already_pairing? && !@pull.reviewer?(current_reviewer)
  end
end
