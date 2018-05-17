class Reviewers::ReviewsController < Reviewers::BaseController
  before_action :set_pull, only: %i(new create)
  before_action :check_pull, only: %i(new create)

  # GET /reviewers/pulls/:pull_id/reviews/file
  def new
    @review = Review.new
  end

  # POST /reviewers/pulls/:pull_id/reviews
  def create
    # データの作成とGHAへのリクエストを分離することで例外処理に対応する
    ActiveRecord::Base.transaction do
      @review = current_reviewer.reviews.ready_to_review!(@pull)
    end
    ActiveRecord::Base.transaction do
      @review.reflect!
    end
    redirect_to [:reviewers, @pull], success: t('.success')
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

  def check_pull
    redirect_to reviewers_dashboard_url unless @pull.agreed?
  end
end
