class ReviewersController < Reviewers::BaseController
  before_action :check_reviewer, except: %i(pending)

  def dashboard
    @pulls = Repo.pulls_suitable_for(current_reviewer).order(created_at: :desc).page(params[:page])
    @q = Pull.ransack(params[:q])
  end

  def my_page
    @reviewed_pulls = Pull.includes(repo: :skilling).where(id: current_reviewer.reviews.comment.pluck(:pull_id)).page(params[:pages])
    @pending_reviews = current_reviewer.reviews.includes(pull: [repo: [skillings: :skill]]).pending
  end

  def pending
    redirect_to :reviewers_dashboard unless current_reviewer.pending?
  end
end
