class Reviewers::PullsController < Reviewers::BaseController
  before_action :set_pull, only: %i(show update)
  before_action :check_reviewer, only: %i(show update)

  def show
  end

  def update
    case params[:status]
    when 'request_reviewed', 'canceled'
      @pull.agreed!
      @pull.update!(reviewer: current_reviewer)
    when 'agreed'
      if current_reviewer.reviews.find_by(pull: @pull).nil?
        current_reviewer.target_review_comments(@pull).delete_all if current_reviewer.target_review_comments(@pull).present?
        @pull.canceled!
        @pull.update!(reviewer: nil)
      else
        return redirect_to [:reviewers, @pull], success: 'すでにレビュー済みのためキャンセルできません'
      end
    end
    redirect_to [:reviewers, @pull], success: 'あなたがレビュー担当になりました！2時間以内にレビューをしてあげましょう。'
  end

  private

  def set_pull
    @pull = Pull.find(params[:id])
  end

  def check_reviewer
    redirect_to reviewers_dashboard_url if  @pull.already_pairing? && !@pull.reviewer?(current_reviewer)
  end
end
