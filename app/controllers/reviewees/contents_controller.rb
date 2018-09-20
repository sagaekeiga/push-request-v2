class Reviewees::ContentsController < Reviewees::BaseController
  before_action :set_repo, only: %i(index show update)
  before_action :set_content, only: %i(show update)
  skip_before_action :verify_authenticity_token, only: %i(update)

  def index
    @dir_or_files = @repo.contents.top
    @readme = Github::Request.github_exec_fetch_readme(@repo)
  end

  def show
    @dir_or_files = @content.children.sub(@content).decorate
  end

  def update
    case @content.status
    when 'hidden'
      @content.showing!
      @content.children.each(&:showing!) if @content.children.present?
    when 'showing'
      @content.hidden!
      @content.children.each(&:hidden!) if @content.children.present?
    end
    respond_to do |format|
      format.html
      format.json do
        render json: {
          status: @content.status
        }
      end
    end
  end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id]).decorate
  end

  def set_content
    @content = Content.find(params[:id])
    @file = Github::Request.github_exec_fetch_file_content!(@repo, @content) if @content.file?
  end
end
