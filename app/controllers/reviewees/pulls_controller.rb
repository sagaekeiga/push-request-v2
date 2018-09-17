class Reviewees::PullsController < Reviewees::BaseController
  before_action :set_pull, only: %i(update)
  before_action :check_present_changed_files, only: %i(update)

  def update
    if @pull.update(status: params[:status])
      redirect_to reviewees_pulls_url
    else
      @pulls = current_reviewee.pulls.order(created_at: :desc)
      render 'reviewees/pulls'
    end
  end

  private

  def set_pull
    @pull = current_reviewee.pulls.find(params[:id])
  end

  # 変更点のないPRはレビュワーはコメントできない
  def check_present_changed_files
    redirect_to request.referrer, danger: t('reviewees.views.no_changed_files') if @pull.changed_files.none?
  end
end
