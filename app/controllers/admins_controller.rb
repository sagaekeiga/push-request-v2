class AdminsController < Admins::BaseController
  def dashboard
    @pending_reviewers = Reviewer.order(created_at: :desc).pending.page(params[:page]).select{ |reviewer| reviewer.github_account.present? }
  end
end
