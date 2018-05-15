class Reviewers::ReviewsController < Reviewers::BaseController
  before_action :set_pull, only: %i(new create)

  # GET /reviewers/pulls/:pull_id/reviews/file
  def new
    @review = Review.new
  end

  # POST /reviewers/pulls/:pull_id/reviews
  def create
    ActiveRecord::Base.transaction do
      @review = current_reviewer.reviews.new(pull: @pull)
      @review.save!
      review_comments = current_reviewer.review_comments.where(changed_file: @pull.changed_files)
      review_comments.each { |review_comment| review_comment.update!(review: @review) }
    end
    if @review.reflect
      redirect_to [:reviewers, @pull], success: '成功しました'
    else
      @review = Review.new
      render :new
    end
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    @review = Review.new
    render :new
  end

  private

  def set_pull
    @pull = Pull.find(params[:pull_id])
  end
end
