class Reviewers::PullsController < Reviewers::BaseController
  before_action :set_pull, only: %i(show)

  def show
  end

  private

  def set_pull
    @pull = Pull.find(params[:id])
  end
end
