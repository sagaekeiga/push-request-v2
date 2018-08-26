class PullsController < Reviewers::BaseController
  def index
    @q = Repo.with_public_pulls.order(created_at: :desc).ransack(params[:q])
    @pulls = @q.result(distinct: true).page(params[:pages])
  end
end
