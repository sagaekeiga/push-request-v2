class AdminsController < Admins::BaseController
  def dashboard
    @pending_reviewers = Reviewer.pending.includes(:github_account)
  end
end
