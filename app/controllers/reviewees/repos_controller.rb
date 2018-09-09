class Reviewees::ReposController < Reviewees::BaseController
  before_action :set_repo, only: %i(update)

  def update
    case @repo.status
    when 'hidden'
      @repo.showing!
    when 'showing'
      @repo.hidden!
    end
    redirect_to reviewees_repo_contents_url(@repo), success: '公開しました'
  end

  private

  def set_repo
    @repo = Repo.find(params[:id]).decorate
  end
end
