class Admins::ReviewsController < Admins::BaseController
  before_action :set_review, only: %i(show update destroy)

  def index
    @pending_reviews = Review.pending
  end

  def show
    @pull = @review.pull
    @changed_files = @review.pull.files_changed.decorate
  end

  def update
    # データの作成とGHAへのリクエストを分離することで例外処理に対応する
    ActiveRecord::Base.transaction do
      case params[:review][:event]
      when 'approve'
        @review.update!(reason: params[:review][:reason])
        @review.github_exec_review!
        ReviewerMailer.approve_review(@review).deliver_later
      when 'non_approve'
        @review.update!(reason: params[:review][:reason])
        @review.refused!
        @review.pull.request_reviewed!
        ReviewerMailer.refused_review(@review).deliver_later
      end
    end
    redirect_to [:admins, @review], success: t('.success')
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    @changed_files = @review.pull.files_changed
    flash[:danger] = '承認に失敗しました'
    render :show
  end

  private

  def set_review
    @review = Review.find(params[:id])
  end
end
