class RevieweesController < Reviewees::BaseController
  def dashboard
    @reviewee = current_reviewee.decorate
  end

  def repos
    @repos = current_reviewee.repos.order(created_at: :desc).page(params[:page])
  end
end
