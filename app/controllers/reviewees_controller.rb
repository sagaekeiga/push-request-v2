class RevieweesController < Reviewees::BaseController
  def dashboard
    @reviewee = current_reviewee.decorate
  end

  def repos
    @repos = current_reviewee.repos.or(Repo.owned_by_orgs(current_reviewee)).order(created_at: :desc).page(params[:page])
  end
end
