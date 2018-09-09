class Reviewees::ContentsController < Reviewees::BaseController
  before_action :set_repo, only: %i(index update)
  before_action :set_content, only: %i(show update)
  skip_before_action :verify_authenticity_token, only: %i(update)

  def index
    @dir_or_files = @repo.contents.order(file_type: :desc, name: :asc).includes(:parent).select { |content| content.parent.nil? }
  end

  def show
    @dir_or_files = @content.children.order(file_type: :desc, name: :asc).includes(:repo).decorate if @content.dir?
  end

  def update
    case @content.status
    when 'hidden'
      @content.showing!
    when 'showing'
      @content.hidden!
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
  end
end
