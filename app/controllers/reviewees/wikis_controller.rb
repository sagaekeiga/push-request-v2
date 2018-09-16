class Reviewees::WikisController < Reviewees::BaseController
  before_action :set_repo, only: %i(index import show update)
  before_action :set_wikis, only: %i(index show)
  before_action :set_home_wiki, only: %i(index show)
  before_action :set_wiki, only: %i(show update)
  skip_before_action :verify_authenticity_token, only: %i(update)

  def index
    @home_wiki = @repo.wikis.find_by(title: 'Home')
  end

  def show
  end

  def update
    return render json: { status: @wiki.switch_status! } if params[:status]
    if @wiki.update(wiki_params)
      redirect_to [:reviewee, @repo, @wiki], success: '更新しました'
    else
      render :edit
    end
  end

  # POST /reviewees/repos/:repo_id/wikis/import
  def import
    import = @repo.import_wikis!(params[:file], current_reviewee)
    redirect_to reviewees_repo_wikis_url(@repo), success: import ? 'インポートが完了しました' : 'インポートに失敗しました'
  end

  private

  def set_repo
    @repo = current_reviewee.repos.find(params[:repo_id])
  end

  def set_wikis
    @wikis = @repo.wikis.where.not(title: 'Home')
  end

  def set_home_wiki
    @home_wiki = @repo.wikis.find_by(title: 'Home')
  end

  def set_wiki
    @wiki = @repo.wikis.find(params[:id])
  end

  def wiki_params
    params.require(:wiki).permit(:title, :body)
  end
end
