class Reviewers::ReviewCommentsController < ApplicationController
  protect_from_forgery except: %i(create)

  def create
    reviewer = Reviewer.find(params[:reviewer_id])
    changed_file = ChangedFile.find(params[:changed_file_id])

    return render json: { status: 'failed' } if changed_file.nil? || reviewer.nil?

    review_comment = changed_file.review_comments.new(
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
end
