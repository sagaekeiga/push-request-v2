class Reviewers::ReviewsController < Reviewers::BaseController
  before_action :set_pull, only: %i(new create)

  # GET /reviewers/pulls/:pull_id/reviews/file
  def new
    @review = Review.new
  end

  # POST /reviewers/pulls/:pull_id/reviews
  def create
    ActiveRecord::Base.transaction do
      Review.create_review!(params[:reviews], @pull, current_reviewer)
      current_reviewer.reviews.request_review!(@pull)
    end
    redirect_to [:reviewers, @pull], success: '成功しました'
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    render :new
  end

  private

  def set_pull
    @pull = Pull.find(params[:pull_id])
  end
end
