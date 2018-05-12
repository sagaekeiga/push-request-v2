class Users::PullsController < Users::BaseController
  before_action :set_pull, only: %i(update)

  # @TODO キャンセルされた場合は、PRにキャンセル通知がコメントされる。
  def update
    @pull.update(status: params[:status])
    redirect_to users_pulls_url
  end

  private

  def set_pull
    @pull = current_user.pulls.find(params[:id])
  end
end
