class Reviewers::ReviewCommentsController < ApplicationController
  protect_from_forgery except: %i(create)
  before_action :set_changed_file, only: %i(create)
  before_action :set_pull, only: %i(create)
  before_action :check_pull, only: %i(create)

  def create
    reviewer = Reviewer.find(params[:reviewer_id])
    @changed_file = ChangedFile.find(params[:changed_file_id])

    return render json: { status: 'failed' } if @changed_file.nil? || reviewer.nil?

    review_comment = @changed_file.review_comments.new(
      position: params[:position],
      path: params[:path],
      body: params[:body],
      reviewer: reviewer
    )

    if review_comment.save
      render json: { status: 'success' }
    else
      render json: { status: 'failed' }
    end
  end

  private

  def set_changed_file
    @changed_file = ChangedFile.find(params[:changed_file_id])
  end

  def set_pull
    @pull = @changed_file.pull
  end

  def check_pull
    redirect_to reviewers_dashboard_url unless @pull.agreed?
  end
end
