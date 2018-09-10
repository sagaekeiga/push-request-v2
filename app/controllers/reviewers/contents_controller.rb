class Reviewers::ContentsController < Reviewers::BaseController
  before_action :set_repo, only: %i(index)
  before_action :set_content, only: %i(show)

  def index
    @dir_or_files = @repo.contents.order(file_type: :desc, name: :asc).includes(:parent).select { |content| content.parent.nil? }
  end

  def show
    @dir_or_files = @content.children.order(file_type: :desc, name: :asc).includes(:repo).decorate if @content.dir?
  end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id]).decorate
  end

  def set_content
    @content = Content.find(params[:id])
  end
end
