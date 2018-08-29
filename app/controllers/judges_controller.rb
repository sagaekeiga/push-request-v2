class JudgesController < ApplicationController

  http_basic_authenticate_with name: "sagaekeiga", password: "s19930528"

  def index
    @reviewers = Reviewer.includes(:github_account).pending.order(created_at: :desc)
  end

  def update
    case params[:status]
    when 'pending'
      reviewer = Reviewer.pending.find(params[:id])
      reviewer.active!
      ReviewerMailer.ok(reviewer).deliver_later
    end
    redirect_to :judges
  end
end
