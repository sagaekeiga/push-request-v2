class AdminsController < Admins::BaseController
  def dashboard
    @pending_reviewers = Reviewer.pending.page(params[:page])
  end
end
