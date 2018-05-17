class Reviewers::ReviewsController < Reviewers::BaseController
  before_action :set_pull, only: %i(new create)

  # GET /reviewers/pulls/:pull_id/reviews/file
  def new
    @review = Review.new
  end

  # POST /reviewers/pulls/:pull_id/reviews
  def create
    ActiveRecord::Base.transaction do
      current_reviewer.reviews.ready_to_review!(@pull)
    end
    if @review.reflect
      @review.pull.reviewed!
      redirect_to [:reviewers, @pull], success: t('.success')
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
