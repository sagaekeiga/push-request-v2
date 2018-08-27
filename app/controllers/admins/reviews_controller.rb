class Admins::ReviewsController < Admins::BaseController
  before_action :set_review, only: %i(show update)

  def index
    @pending_reviews = Review.pending
  end

  def show
    @pull = @review.pull
    @changed_files = @review.pull.last_committed_changed_files.decorate
  end

  def update
    # データの作成とGHAへのリクエストを分離することで例外処理に対応する
    ActiveRecord::Base.transaction do
      @review.github_exec_review!
    end
    redirect_to [:admins, @review], success: t('.success')
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    @changed_files = @review.pull.last_committed_changed_files.decorate
    flash[:danger] = '承認に失敗しました'
    render :show
  end

  private

  def set_review
    @review = Review.find(params[:id])
  end
end
