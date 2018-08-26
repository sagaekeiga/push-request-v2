class RevieweesController < Reviewees::BaseController
  def dashboard
    @reviewee = current_reviewee.decorate
  end

  # @TODO コントローラを専用で作成してもいい気がする。
  def pulls
    @pulls = current_reviewee.pulls.includes(:repo).order(updated_at: :desc).page(params[:page])
  end

  def repos
    @repos = current_reviewee.repos.order(created_at: :desc).page(params[:page])
  end
end
