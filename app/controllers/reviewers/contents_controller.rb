class Reviewers::ContentsController < Reviewers::BaseController
  before_action :set_repo, only: %i(index show)
  before_action :set_content, only: %i(show)
  skip_before_action :verify_authenticity_token, only: %i(search)
  skip_before_action :set_skill!, only: %i(search)
  skip_before_action :authenticate_reviewer!, only: %i(search)

  def index
    @dir_or_files = @repo.contents.top
    @readme = @repo.contents.find_by(name: 'README.md')
  end

  def show
    @dir_or_files = @content.children.sub(@content).decorate
  end

  def search
    repo = Repo.find(params[:repo_id])
    contents = repo.contents.where('content LIKE ?', "%#{params[:keyword]}%").pluck(:content)
    render json: { contents: contents }
  end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id]).decorate
  end

  def set_content
    @content = Content.find(params[:id])
  end
end
