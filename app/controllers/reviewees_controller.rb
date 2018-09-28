class RevieweesController < Reviewees::BaseController
  def dashboard
    @reviewee = current_reviewee.decorate
  end

  def repos
    @repos = current_reviewee.viewable_repos.page(params[:page])
  end
end
