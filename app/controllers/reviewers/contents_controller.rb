class Reviewers::ContentsController < Reviewers::BaseController
  before_action :set_repo, only: %i(index show)
  before_action :set_content, only: %i(show)

  def index
    @dir_or_files = @repo.contents.top
    @readme = @repo.contents.find_by(name: 'README.md')
    @res_readme = Github::Request.github_exec_fetch_readme(@repo)
  end

  def show
    @dir_or_files = @content.children.sub(@content).decorate
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
