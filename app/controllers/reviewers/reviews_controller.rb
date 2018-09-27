class Reviewers::ReviewsController < Reviewers::BaseController
  before_action :set_pull, only: %i(new create)
  before_action :check_pending_review, only: %i(new create)

  # GET /reviewers/pulls/:pull_id/reviews/file
  def new
    @review = Review.new
    @changed_files = @pull.files_changed.decorate
    numberes = @pull.body.scan(/#\d+/)&.map{ |num| num.delete('#').to_i }
    @issues = @pull.repo.issues.where(number: numberes)
  end

  # POST /reviewers/pulls/:pull_id/reviews
  def create
    # データの作成とGHAへのリクエストを分離することで例外処理に対応する
    ActiveRecord::Base.transaction do
      @review = current_reviewer.reviews.ready_to_review!(@pull, params[:review][:body])
    end
    redirect_to [:reviewers, @pull], success: t('.success')
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    @review = Review.new
    @changed_files = @pull.files_changed
    flash[:danger] = 'レビューに失敗しました'
    render :new
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:pull_token]).decorate
  end

  def check_pending_review
    @pending_review = @pull.reviews.pending.first if @pull.reviews
  end
end
