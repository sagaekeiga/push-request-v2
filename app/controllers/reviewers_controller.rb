class ReviewersController < Reviewers::BaseController
  def dashboard
    @pulls = Repo.pulls_suitable_for(current_reviewer).order(created_at: :desc).page(params[:page])
    @q = Pull.ransack(params[:q])
  end

  def my_page
    @working_pulls = current_reviewer.pulls.includes(:repo).agreed.decorate.select{ |pull| (((Time.at(pull.updated_at) + 2.hours) - Time.now) / 60) > 0 }
    @reviewed_pulls = Pull.includes(:repo).where(id: current_reviewer.reviews.comment.pluck(:pull_id)).page(params[:pages])
  end
end
