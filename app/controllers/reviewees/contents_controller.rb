class Reviewees::ContentsController < Reviewees::BaseController
  before_action :set_repo, only: %i(index)
  before_action :set_content, only: %i(show)

  def index
    @contents = @repo.contents.order(file_type: :desc, name: :asc).select { |content| content.parent.nil? }
  end

  def show
    @contents = @content.children.order(file_type: :desc, name: :asc).includes(:repo) if @content.dir?
  end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id])
  end

  def set_content
    @content = Content.find(params[:id])
  end
end
