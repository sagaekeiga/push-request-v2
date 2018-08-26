class JudgesController < ApplicationController

  http_basic_authenticate_with name: "sagaekeiga", password: "s19930528"

  def index
    @reviewers = Reviewer.includes(:github_account).pending.order(created_at: :desc)
  end

  def update
    reviewer = Reviewer.pending.find(params[:reviewer_id])
    reviewer.active!
    ReviewerMailer.ok(reviewer).deliver_later
    redirect_to :judges
  end
end
