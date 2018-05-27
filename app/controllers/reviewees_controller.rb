class RevieweesController < Reviewees::BaseController
  def dashboard
  end

  # @TODO コントローラを専用で作成してもいい気がする。
  def pulls
    @pulls = current_reviewee.pulls.order(created_at: :desc)
  end

  def repos
    @repos = current_reviewee.repos.order(created_at: :desc)
  end
end
