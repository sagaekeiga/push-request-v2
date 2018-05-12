class Reviewees::PullsController < Reviewees::BaseController
  before_action :set_pull, only: %i(update)

  # @TODO キャンセルされた場合は、PRにキャンセル通知がコメントされる。
  def update
    @pull.update(status: params[:status])
    redirect_to reviewees_pulls_url
  end

  private

  def set_pull
    @pull = current_reviewee.pulls.find(params[:id])
  end
end
