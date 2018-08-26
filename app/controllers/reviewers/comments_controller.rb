class Reviewers::CommentsController < Reviewers::BaseController
  before_action :set_pull, only: %i(create update destroy)

  def create
    @review = current_reviewer.reviews.new(
      comment_params.merge(
        event: :issue_comment,
        pull_id: @pull.id
      )
    )
    if @review.github_exec_issue_comment!
      redirect_to [:reviewers, @pull]
    else
      render 'reviewers/pulls/show'
    end
  end

  def update
  end

  def destroy
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:pull_token])
  end

  def comment_params
    params.require(:review).permit(:body, :status, :pull_id)
  end
end
